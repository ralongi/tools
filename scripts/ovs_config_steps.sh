iface=p6p1

ipaddr=120

con_name="static-$iface"
ovsbr="myovs"
intport="intport0"
vxlan_mtu=$(($mtu-50))
vxlan_vlan_mtu=$(($mtu-50-4))
gre_mtu=$(($mtu-20-4-14))
gre_vlan_mtu=$(($mtu-20-4-14-4))
tag="10"

#client:

intport_ip4=192.168.120.2

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

#server:

intport_ip4=192.168.120.4

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










ovs_cfg()
{
    local use_vm=${use_vm:-"no"}

    ovs-vsctl --if-exists del-br $ovsbr
    ovs-vsctl add-br $ovsbr
    ovs-vsctl add-port $ovsbr $intport -- set interface $intport type=internal
    ovs-vsctl add-port $ovsbr $iface
    if [ $use_vm == yes ]; then
        local vm_status=$(virsh list --all | grep $vm | awk '{ print $3 }')
        echo "The current status of VM $vm is: $vm_status"
        if [[ $vm_status != running ]]; then
            # start vm and wait for it to boot up
            virsh start $vm
            sleep 90
        fi

        # set MTU on VM
        vmsh run_cmd $vm "ip link set dev $iface_vm mtu $mtu"

        # start netserver (if necessary)
        vm_netperf_start

        # remove $intport since it's not needed for VM to VM tests, add vnet to ovsbr and set vnet vlan tag and mtu
        ovs-vsctl del-port $ovsbr $intport
        ovs-vsctl add-port $ovsbr $vnet        
        ip link set dev $vnet mtu $mtu
    fi
    ip link set dev $iface mtu $mtu
    ip link set dev $intport mtu $mtu
    ip link set dev $ovsbr up
    ip link set dev $iface up
    ip link set dev $intport up
    ip addr add $intport_ip4/24 dev $intport
    ip -6 addr add $intport_ip6/64 dev $intport
    echo "The current time is: $(date +"%H:%M:%S")"
    sleep 10
    echo "The current time is: $(date +"%H:%M:%S")"
    get_current_link_cfg
}

ovs_vlan_cfg()
{
    local use_vm=${use_vm:-"no"}

    ovs-vsctl --if-exists del-br $ovsbr
    ovs-vsctl add-br $ovsbr
    ovs-vsctl add-port $ovsbr $intport -- set interface $intport type=internal
    ovs-vsctl set port $intport tag=$tag
    ovs-vsctl add-port $ovsbr $iface
    if [ $use_vm == yes ]; then
        local vm_status=$(virsh list --all | grep $vm | awk '{ print $3 }')
        echo "The current status of VM $vm is: $vm_status"
        if [[ $vm_status != running ]]; then
            # start vm and wait for it to boot up
            virsh start $vm
            sleep 90
        fi

        # set MTU on VM
        vmsh run_cmd $vm "ip link set dev $iface_vm mtu $mtu"

        # start netserver (if necessary)
        vm_netperf_start

        # remove $intport since it's not needed for VM to VM tests, add vnet to ovsbr and set vnet vlan tag and mtu
        ovs-vsctl del-port $ovsbr $intport
        ovs-vsctl add-port $ovsbr $vnet
        ovs-vsctl set port $vnet tag=$tag    
        ip link set dev $vnet mtu $mtu
    fi
    ip link set dev $iface mtu $mtu
    ip link set dev $intport mtu $mtu
    ip link set dev $ovsbr up
    ip link set dev $iface up
    ip link set dev $intport up
    ip addr add $intport_ip4/24 dev $intport
    ip -6 addr add $intport_ip6/64 dev $intport
    echo "The current time is: $(date +"%H:%M:%S")"
    sleep 10
    echo "The current time is: $(date +"%H:%M:%S")"
    get_current_link_cfg
}

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

get_nic_driver_info()
{
    echo "NIC driver information for $iface: "
    echo -e
    ethtool -i $iface
    echo -e
    ethtool $iface
    echo -e
    ethtool -k $iface
    echo -e
}


