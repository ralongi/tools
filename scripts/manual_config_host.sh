#!/bin/bash

rhel_version=$(cut -f1 -d. /etc/redhat-release | sed 's/[^0-9]//g')

CLIENT="netqe7.knqe.lab.eng.bos.redhat.com"
SERVER="netqe8.knqe.lab.eng.bos.redhat.com"

host=$(hostname)
ipaddr=120

iface="p2p1"
if [ $# -gt 0 ]; then iface=$1; fi

mtu=1500
vxlan_mtu=$(($mtu-58))
vxlan_vlan_mtu=$(($mtu-58))

if [ $host == $CLIENT ]; then
    ip4addr=192.168.$((ipaddr + 0)).2
    ip4addr_peer=192.168.$((ipaddr + 0)).4
    ip6addr=2014:$((ipaddr + 0))::2
    ip6addr_peer=2014:$((ipaddr + 0))::4

    ip4addr_vm=192.168.$((ipaddr + 50)).2
    ip4addr_vm_peer=192.168.$((ipaddr + 50)).4
    ip6addr_vm=2015:$((ipaddr + 50))::2
    ip6addr_vm_peer=2015:$((ipaddr + 50))::4

    intport_ip4=192.168.$((ipaddr + 100)).2
    intport_ip4_peer=192.168.$((ipaddr + 100)).4
    intport_ip6=2016:$((ipaddr + 100))::2
    intport_ip6_peer=2016:$((ipaddr + 100))::4

elif [ $host == $SERVER ]; then
    ip4addr=192.168.$((ipaddr + 0)).4
    ip4addr_peer=192.168.$((ipaddr + 0)).2
    ip6addr=2014:$((ipaddr + 0))::4
    ip6addr_peer=2014:$((ipaddr + 0))::2

    ip4addr_vm=192.168.$((ipaddr + 50)).4
    ip4addr_vm_peer=192.168.$((ipaddr + 50)).2
    ip6addr_vm=2015:$((ipaddr + 50))::4
    ip6addr_vm_peer=2015:$((ipaddr + 50))::2

    intport_ip4=192.168.$((ipaddr + 100)).4
    intport_ip4_peer=192.168.$((ipaddr + 100)).2
    intport_ip6=2016:$((ipaddr + 100))::4
    intport_ip6_peer=2016:$((ipaddr + 100))::2

else
	echo "This host is not the client or server!"
	exit 1

fi

ip addr add dev "$iface" "$ip4addr"/24; ip -6 addr add dev "$iface" "$ip6addr"/64; ip link set dev $iface up

get_current_link_cfg()
{
    ip a | grep -A4 $iface
    echo -e
	ip a | grep $intport; if [[ $? == 0 ]]; then ip a | grep -A4 $intport; fi
    echo -e
    ip r
    echo -e
    ip -6 r
    echo -e
    ovs-vsctl show
    echo -e
	if [ $use_vm == yes ]; then
		    ip a | grep -A4 $vnet
    		echo -e
		    vmsh run_cmd $vm "ip a" > ip_a.tmp
			echo "Configuration on VM $iface_vm: "
    		echo -e
    		grep -A4 $iface_vm ip_a.tmp
			echo -e
	fi
}

ovs_install()
{
	local rhel_version=$(cut -f1 -d. /etc/redhat-release | sed 's/[^0-9]//g')
	# specify ovs rpm/version to be used
	if (($rhel_version == 6)); then
    	openvswitch_rpm=${openvswitch_rpm:-"http://download.eng.bos.redhat.com/brewroot/packages/openvswitch/2.3.0/1.el6/x86_64/openvswitch-2.3.0-1.el6.x86_64.rpm"}
	elif (($rhel_version == 7)); then
    	openvswitch_rpm=${openvswitch_rpm:-"http://download.eng.bos.redhat.com/brewroot/packages/openvswitch/2.3.2/1.el7/x86_64/openvswitch-2.3.2-1.el7.x86_64.rpm"}
	fi
	
	# install openssl
	yum -y install openssl

    # install, enable, start ovs
    timeout 60s bash -c "until ping -c3 download.bos.redhat.com; do sleep 10; done"
    rpm -ivh $openvswitch_rpm

    if (($rhel_version <= 6)); then
	service openvswitch start; chkconfig openvswitch on
	else
	systemctl start openvswitch.service; systemctl enable openvswitch.service
    fi
}

ovs_install

ovs_vxlan_cfg()
{
    local use_vm=${use_vm:-"no"}
    local use_vxlan="yes"
	local ovsbr="myovs"
	local vxlan_tun="vxlan1"
	local intport="intport0"

    ovs-vsctl --if-exists del-br $ovsbr
    ovs-vsctl add-br $ovsbr
    ip link set dev $ovsbr up
    ovs-vsctl add-port $ovsbr $vxlan_tun -- set interface $vxlan_tun type=vxlan options:remote_ip=$ip4addr_peer
    ovs-vsctl add-port $ovsbr $intport -- set interface $intport type=internal
    if [ $use_vm == yes ]; then
        local vm_status=$(virsh list --all | grep $vm | awk '{ print $3 }')
        echo "The current status of VM $vm is: $vm_status"
        if [[ $vm_status != running ]]; then
            # start vm and wait for it to boot up
            virsh start $vm
            sleep 90
        fi

        # set MTU on VM
        vmsh run_cmd $vm "ip link set dev $iface_vm mtu $vxlan_mtu"

        # start netserver (if necessary)
        vm_netperf_start
    
        # remove $intport since it's not needed for VM to VM tests, add vnet to ovsbr and set vnet mtu
        ovs-vsctl del-port $ovsbr $intport
        ovs-vsctl add-port $ovsbr $vnet
        #ip link set dev $vnet mtu $mtu
    fi
    ip addr add $ip4addr/24 dev $iface
    ip link set dev $iface mtu $mtu
    ip link set dev $intport mtu $vxlan_mtu || true
    ip link set dev $iface up
    ip link set dev $intport up
    ip addr add $intport_ip4/24 dev $intport
    ip -6 addr add $intport_ip6/64 dev $intport
    sleep 10
    get_current_link_cfg
}

ovs_vxlan_cfg
