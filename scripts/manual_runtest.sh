#!/bin/bash
# vim: dict=/usr/share/beakerlib/dictionary.vim cpt=.,w,b,u,t,i,k sts=4 sw=4 et
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   runtest.sh of /kernel/networking/openvswitch/tests/perf_check
#   Author: Rick Alongi <ralongi@redhat.com>
#
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   Copyright (c) 2015 Red Hat, Inc.
#
#   This copyrighted material is made available to anyone wishing
#   to use, modify, copy, or redistribute it subject to the terms
#   and conditions of the GNU General Public License version 2.
#
#   This program is distributed in the hope that it will be
#   useful, but WITHOUT ANY WARRANTY; without even the implied
#   warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
#   PURPOSE. See the GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public
#   License along with this program; if not, write to the Free
#   Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
#   Boston, MA 02110-1301, USA.
#
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

set -x

# variables
PACKAGE="kernel"

#!/bin/bash

# config_host.sh script to run after provisioning system

# usage: ssh root@host.domain < config_host.sh

# rhel version
rhel_version=$(cut -f1 -d. /etc/redhat-release | sed 's/[^0-9]//g')

# install beaker-client.repo
wget -O /etc/yum.repos.d/beaker-client.repo http://download.lab.bos.redhat.com/beakerrepos/beaker-client-RedHatEnterpriseLinux.repo

# install beaker related packages
yum -y install rhts-test-env beakerlib rhts-devel rhts-python beakerlib-redhat beaker-client beaker-redhat

# create beaker-tasks.repo file
(
	echo [beaker-tasks]
	echo name=beaker-tasks
	echo baseurl=http://beaker.engineering.redhat.com/rpms
	echo enabled=1
	echo gpgcheck=0
	echo skip_if_unavailable=1
) > /etc/yum.repos.d/beaker-tasks.repo

git_install()
{
	if [ $# -gt 0 ]; then 
		git_dir=$1
	else
		git_dir="/mnt/git_repo"
	fi

	if rpm -q git 2>/dev/null; then
		echo "Git is already installed; doing a git pull"; cd "$git_dir"/kernel; git pull
		return 0
	else
	    yum -y install git
        mkdir "$git_dir"
		cd "$git_dir" && git clone git://pkgs.devel.redhat.com/tests/kernel
	fi
}

# install git
git_install /mnt/tests

# source necessary files
# include Beaker environment
. /mnt/tests/kernel/networking/common/include.sh || exit 1
 
# include common install functions
. /mnt/tests/kernel/networking/common/install.sh || exit 1

# include common networking functions
. /mnt/tests/kernel/networking/common/network.sh || exit 1
. /mnt/tests/kernel/networking/common/lib/lib_nc_sync.sh || exit 1
#. /mnt/tests/kernel/networking/common/lib/lib_netperf_all.sh || exit 1

# include private common functions
. /mnt/tests/kernel/networking/impairment/networking_common.sh || exit 1
. /mnt/tests/kernel/networking/impairment/install.sh || exit 1
. /mnt/tests/kernel/networking/openvswitch/tests/perf_check/lib_netperf_all.sh || exit 1

# stop security features
iptables_stop_flush && setenforce 0

# update beaker repo files
do_beaker_repo_create

# install miscellaneous packages
# epel repo
epe_install

# netperf
netperf_install
pkill netserver; sleep 2; netserver

# sshpass
sshpass_install

# httpd
httpd_install

# ovs
ovs_install

#virtualization
virt_install

# install ip netns
iproute2_install

# brctl
brctl_install

# NetworkManager
networkmanager_install

# set default password to be used for tests 
password="100yard-"

# rhel version
rhel_version=$(cut -f1 -d. /etc/redhat-release | sed 's/[^0-9]//g')

# pointer to netperf package
pkg_netperf=${pkg_netperf:-"http://pkgs.repoforge.org/netperf/netperf-2.6.0-1.el6.rf.x86_64.rpm"}

# pointer to log file
result_file=${result_file:-"ovs_test_result.log"}

# specify interface and MTU to use for test
iface=${iface:-""}
iface_driver=${iface_driver:-"$(get_iface_driver $iface)"}
mtu=${mtu:-"1500"}
echo "The interface to be used is: $iface."
echo "The driver to be used is: $iface_driver."
echo "The MTU to be used is: $mtu."

vm=${vm:-"g1"}
vm_image_name=${vm_image_name:-""}
vm_image_location=${vm_image_location:-"http://pnate-control-01.lab.bos.redhat.com"}
vm_xml_file=${vm_xml_file:-""}


if [ -z "$JOBID" ]; then
	ipaddr=120
else
	ipaddr=$((JOBID % 100 + 20))
fi

if i_am_client; then
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

else
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
fi

con_name="static-$iface"
ovsbr="myovs"
intport="intport0"
vxlan_mtu=$(($mtu-50))
vxlan_vlan_mtu=$(($mtu-50-4))
gre_mtu=$(($mtu-20-4-14))
gre_vlan_mtu=$(($mtu-20-4-14-4))
tag="10"

# specify ovs rpm/version to be used
if (($rhel_version == 6)); then
    openvswitch_rpm=${openvswitch_rpm:-"http://download.eng.bos.redhat.com/brewroot/packages/openvswitch/2.3.0/1.el6/x86_64/openvswitch-2.3.0-1.el6.x86_64.rpm"}
elif (($rhel_version == 7)); then
    openvswitch_rpm=${openvswitch_rpm:-"http://download.eng.bos.redhat.com/brewroot/packages/openvswitch/2.3.2/1.el7/x86_64/openvswitch-2.3.2-1.el7.x86_64.rpm"}
fi

pkg_netperf=${pkg_netperf:-"http://pkgs.repoforge.org/netperf/netperf-2.6.0-1.el6.rf.x86_64.rpm"}
netperf_time=${netperf_time:-"10"}

do_host_netperf=${do_host_netperf:-"do_host_netperf_all"}
do_vm_netperf=${do_vm_netperf:-"do_vm_netperf_all"}
tcp_threshold=${tcp_threshold:-"9000"}
udp_threshold=${udp_threshold:-"1300"}
tunnel_tcp_threshold=${tunnel_tcp_threshold:-"2500"}
tunnel_udp_threshold=${tunnel_udp_threshold:-"1300"}

vxlan_tun=${vxlan_tun:-"vxlan1"}
gre_tun=${gre_tun:-"gre1"}

vnet=${vnet:-"vnet0"}

up_knl_vm=${up_knl_vm:-"yes"}

#############################################################################

# funtion to obtain interface being used on VM
get_iface_vm()
{
    vmsh run_cmd $vm "ip l l" > ip_a.tmp
    iface_vm=$(grep BROADCAST ip_a.tmp | awk -F ":" '{ print $2 }')
    echo "The interface on the VM is: $iface_vm"
}

# function to update kernel on the VM
update_kernel_vm()
{
	host_k_ver=$(uname -r)
	vm_k_ver=$((vmsh run_cmd $vm "uname -r" > vm_k_ver.txt); awk '/uname -r/{getline; print}' vm_k_ver.txt)
        rm -f vm_k_ver.txt
        
	if [[ "$host_k_ver" == "$vm_k_ver" ]]; then exit 0; fi 

	local intport_ip4_tmp=$(echo $ip4addr_vm | awk -F "." '{ print $1"."$2"."$3"."$4+20 }')
        local host_kernel_rpm=$(uname -r | awk '{
		split($0,v,"-");
		s=v[2];
		do {
			i=index(s,".");
			s=substr(s, i+1)
		} while(i > 0)
		sub("."s,"",v[2])
                print "kernel-"v[1]"-"v[2]"."s".rpm"}')

        echo $host_kernel_rpm > host_kernel_rpm.tmp
        local v1=$(awk -F "-" '{ print $2 }' host_kernel_rpm.tmp)
        local v2=$(awk -F "-" '{ print $3 }' host_kernel_rpm.tmp | awk -F "." '{ print $1"."$2 }')
        local p=$(awk -F "-" '{ print $3 }' host_kernel_rpm.tmp | awk -F "." '{ print $3 }')
        local kernel_firmware=$(awk -F "-" '{ print $1"-firmware""$v2" }' host_kernel_rpm.tmp)

	
        ip addr add dev $intport $intport_ip4_tmp/24
        cd /var/www/html; rm -f *rpm*
	wget http://download.eng.bos.redhat.com/brewroot/packages/kernel/$v1/$v2/$p/$host_kernel_rpm

	vmsh run_cmd $vm "rpm -ivh --nodeps --force http://"$intport_ip4_tmp"/$host_kernel_rpm"
	virsh reboot $vm
	ip addr flush dev $intport $intport_ip4_tmp/24
	sleep 90
}

# functions to configure static/persistent IP addresses
set_ipaddr_rhel6()
{
    #The method below calls the "cfg_static_ip" function from kernel/networking/impairment/networking_common.sh and passes the necessary arguments
    cfg_static_ip $ip4addr $ip6addr $iface $mtu
}

set_ipaddr_rhel7()
{
    #The method below calls functions from kernel/networking/impairment/networking_common.sh and uses nmcli to configure IP addresses
    nmcli_con_del $con_name
    nmcli_cfg_ip $con_name $iface $ip4addr/24 $ip6addr/64
    nmcli_cfg_mtu $mtu $con_name
}

# function to set non-persistent IP addresses for OVS NIC tests
set_ipaddr_nic()
{  
    local use_vm=${use_vm:-"no"}

    ip link set dev $iface mtu $mtu
    ip link set dev $iface up
    ip addr add $ip4addr/24 dev $iface
    ip -6 addr add $ip6addr/64 dev $iface
    sleep 10
    ip r
    echo -e " \n"
    ip -6 r
}

# functions to config OVS, set non-persistent IP addresses for OVS tests
ovs_nic_cfg()
{
    local use_vm=${use_vm:-"no"}

    ovs-vsctl --if-exists del-br $ovsbr
    ovs-vsctl add-br $ovsbr
    ovs-vsctl add-port $ovsbr $iface
    if [ $use_vm == yes ]; then
        # start vm and wait for it to boot up
        virsh start $vm
        sleep 90

        # update kernel on the VM if specified
        if [ $up_knl_vm == yes ]; then
            update_kernel_vm
        fi        

        # get interface to be used on vm, set it to $iface_vm, configure VM
        get_iface_vm
    
        local cmd=(
	    {iptables -F}
	    {ip6tables -F}
	    {setenforce 0}
	    {ip link set dev $iface_vm down}
	    {ip link set dev $iface_vm up}
	    {ip link set dev $iface_vm mtu $mtu}
	    {ip addr flush dev $iface_vm}
	    {ip addr add $ip4addr_vm/24 dev $iface_vm}
	    {ip addr add $ip6addr_vm/64 dev $iface_vm}
	    {pkill netserver\; sleep 2\; netserver}
        )
        vmsh cmd_set $vm "${cmd[*]}"

        # add vnet to ovsbr and set vnet mtu
        ovs-vsctl add-port $ovsbr $vnet
        ip link set dev $vnet mtu $mtu
    fi
    ip link set dev $iface mtu $mtu
    ip link set dev $ovsbr up
    ip link set dev $iface up
    ip addr add $ip4addr/24 dev $ovsbr
    ip -6 addr add $ip6addr/64 dev $ovsbr
    sleep 10
    ip r
    echo -e " \n"
    ip -6 r
    ovs-vsctl show
}

ovs_cfg()
{
    local use_vm=${use_vm:-"no"}

    ovs-vsctl --if-exists del-br $ovsbr
    ovs-vsctl add-br $ovsbr
    ovs-vsctl add-port $ovsbr $intport -- set interface $intport type=internal
    ovs-vsctl add-port $ovsbr $iface
    if [ $use_vm == yes ]; then
        # start vm and wait for it to boot up
        virsh start $vm
        sleep 90

        # update kernel on the VM if specified
        if [ $up_knl_vm == yes ]; then
            update_kernel_vm
        fi

        # get interface to be used on vm, set it to $iface_vm, configure VM
        get_iface_vm
    
        local cmd=(
	    {iptables -F}
	    {ip6tables -F}
	    {setenforce 0}
	    {ip link set dev $iface_vm down}
	    {ip link set dev $iface_vm up}
	    {ip link set dev $iface_vm mtu $mtu}
	    {ip addr flush dev $iface_vm}
	    {ip addr add $ip4addr_vm/24 dev $iface_vm}
	    {ip addr add $ip6addr_vm/64 dev $iface_vm}
	    {pkill netserver\; sleep 2\; netserver}
        )
        vmsh cmd_set $vm "${cmd[*]}"

        # add vnet to ovsbr and set vnet mtu
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
    sleep 10
    ip r
    echo -e " \n"
    ip -6 r
    ovs-vsctl show
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
        # start vm and wait for it to boot up
        virsh start $vm
        sleep 90

        # update kernel on the VM if specified
        if [ $up_knl_vm == yes ]; then
            update_kernel_vm
        fi

        # get interface to be used on vm, set it to $iface_vm, configure VM
        get_iface_vm
    
        local cmd=(
	    {iptables -F}
	    {ip6tables -F}
	    {setenforce 0}
	    {ip link set dev $iface_vm down}
	    {ip link set dev $iface_vm up}
	    {ip link set dev $iface_vm mtu $mtu}
	    {ip addr flush dev $iface_vm}
	    {ip addr add $ip4addr_vm/24 dev $iface_vm}
	    {ip addr add $ip6addr_vm/64 dev $iface_vm}
	    {pkill netserver\; sleep 2\; netserver}
        )
        vmsh cmd_set $vm "${cmd[*]}"

        # add vnet to ovsbr and set vnet mtu
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
    sleep 10
    ip r
    echo -e " \n"
    ip -6 r
    ovs-vsctl show
}

ovs_vxlan_cfg()
{
    local use_vm=${use_vm:-"no"}
    local use_vxlan="yes"    

    ovs-vsctl --if-exists del-br $ovsbr
    ovs-vsctl add-br $ovsbr
    ip link set dev $ovsbr up
    ovs-vsctl add-port $ovsbr $vxlan_tun -- set interface $vxlan_tun type=vxlan options:remote_ip=$ip4addr_peer
    ovs-vsctl add-port $ovsbr $intport -- set interface $intport type=internal
    if [ $use_vm == yes ]; then
        # start vm and wait for it to boot up
        virsh start $vm
        sleep 90

        # update kernel on the VM if specified
        if [ $up_knl_vm == yes ]; then
            update_kernel_vm
        fi

        # get interface to be used on vm, set it to $iface_vm, configure VM
        get_iface_vm
    
        local cmd=(
	    {iptables -F}
	    {ip6tables -F}
	    {setenforce 0}
	    {ip link set dev $iface_vm down}
	    {ip link set dev $iface_vm up}
	    {ip link set dev $iface_vm mtu $vxlan_mtu}
	    {ip addr flush dev $iface_vm}
	    {ip addr add $ip4addr_vm/24 dev $iface_vm}
	    {ip addr add $ip6addr_vm/64 dev $iface_vm}
	    {pkill netserver\; sleep 2\; netserver}
        )
        vmsh cmd_set $vm "${cmd[*]}"

        # add vnet to ovsbr and set vnet mtu
        ovs-vsctl add-port $ovsbr $vnet
        ip link set dev $vnet mtu $vxlan_mtu
    fi
    ip addr add $ip4addr/24 dev $iface
    ip link set dev $iface mtu $mtu
    ip link set dev $intport mtu $vxlan_mtu
    ip link set dev $iface up
    ip link set dev $intport up
    ip addr add $intport_ip4/24 dev $intport
    ip -6 addr add $intport_ip6/64 dev $intport
    sleep 10
    ip r
    echo -e " \n"
    ip -6 r
    ovs-vsctl show
}
    
ovs_vxlan_vlan_cfg()
{
    local use_vm=${use_vm:-"no"}
    local use_vxlan_vlan="yes"

    ovs-vsctl --if-exists del-br $ovsbr
    ovs-vsctl add-br $ovsbr
    ip link set dev $ovsbr up
    ovs-vsctl add-port $ovsbr $vxlan_tun -- set interface $vxlan_tun type=vxlan options:remote_ip=$ip4addr_peer
    ovs-vsctl add-port $ovsbr $intport -- set interface $intport type=internal
    ovs-vsctl set port $intport tag=$tag
    if [ $use_vm == yes ]; then
        # start vm and wait for it to boot up
        virsh start $vm
        sleep 90

        # update kernel on the VM if specified
        if [ $up_knl_vm == yes ]; then
            update_kernel_vm
        fi

        # get interface to be used on vm, set it to $iface_vm, configure VM
        get_iface_vm
    
        local cmd=(
	    {iptables -F}
	    {ip6tables -F}
	    {setenforce 0}
	    {ip link set dev $iface_vm down}
	    {ip link set dev $iface_vm up}
	    {ip link set dev $iface_vm mtu $vxlan_vlan_mtu}
	    {ip addr flush dev $iface_vm}
	    {ip addr add $ip4addr_vm/24 dev $iface_vm}
	    {ip addr add $ip6addr_vm/64 dev $iface_vm}
	    {pkill netserver\; sleep 2\; netserver}
        )
        vmsh cmd_set $vm "${cmd[*]}"

        # add vnet to ovsbr and set vnet mtu
        ovs-vsctl add-port $ovsbr $vnet
        ip link set dev $vnet mtu $vxlan_vlan_mtu
    fi
    ip link set dev $iface mtu $mtu
    ip link set dev $intport mtu $vxlan_vlan_mtu
    ip link set dev $iface up
    ip link set dev $intport up
    ip addr add $ip4addr/24 dev $iface
    ip addr add $intport_ip4/24 dev $intport
    ip -6 addr add $intport_ip6/64 dev $intport
    sleep 10
    ip r
    echo -e " \n"
    ip -6 r
    ovs-vsctl show
}

ovs_gre_cfg()
{
    local use_vm=${use_vm:-"no"}
    local use_gre="yes"

    ovs-vsctl --if-exists del-br $ovsbr
    ovs-vsctl add-br $ovsbr
    ip link set dev $ovsbr up
    ovs-vsctl add-port $ovsbr $gre_tun -- set interface $gre_tun type=gre options:remote_ip=$ip4addr_peer
    ovs-vsctl add-port $ovsbr $intport -- set interface $intport type=internal
    if [ $use_vm == yes ]; then
        # start vm and wait for it to boot up
        virsh start $vm
        sleep 90

        # update kernel on the VM if specified
        if [ $up_knl_vm == yes ]; then
            update_kernel_vm
        fi

        # get interface to be used on vm, set it to $iface_vm, configure VM
        get_iface_vm
    
        local cmd=(
	    {iptables -F}
	    {ip6tables -F}
	    {setenforce 0}
	    {ip link set dev $iface_vm down}
	    {ip link set dev $iface_vm up}
	    {ip link set dev $iface_vm mtu $gre_mtu}
	    {ip addr flush dev $iface_vm}
	    {ip addr add $ip4addr_vm/24 dev $iface_vm}
	    {ip addr add $ip6addr_vm/64 dev $iface_vm}
	    {pkill netserver\; sleep 2\; netserver}
        )
        vmsh cmd_set $vm "${cmd[*]}"

        # add vnet to ovsbr and set vnet mtu
        ovs-vsctl add-port $ovsbr $vnet
        ip link set dev $vnet mtu $gre_mtu
    fi
    ip link set dev $iface mtu $mtu
    ip link set dev $intport mtu $gre_mtu
    ip link set dev $iface up
    ip link set dev $intport up
    ip addr add $ip4addr/24 dev $iface
    ip addr add $intport_ip4/24 dev $intport
    ip -6 addr add $intport_ip6/64 dev $intport
    sleep 10
    ip r
    echo -e " \n"
    ip -6 r
    ovs-vsctl show
}
    
ovs_gre_vlan_cfg()
{
    local use_vm=${use_vm:-"no"}
    local use_gre_vlan="yes"

    ovs-vsctl --if-exists del-br $ovsbr
    ovs-vsctl add-br $ovsbr
    ip link set dev $ovsbr up
    ovs-vsctl add-port $ovsbr $gre_tun -- set interface $gre_tun type=gre options:remote_ip=$ip4addr_peer
    ovs-vsctl add-port $ovsbr $intport -- set interface $intport type=internal
    ovs-vsctl set port $intport tag=$tag
    if [ $use_vm == yes ]; then
        # start vm and wait for it to boot up
        virsh start $vm
        sleep 90

        # update kernel on the VM if specified
        if [ $up_knl_vm == yes ]; then
            update_kernel_vm
        fi

        # get interface to be used on vm, set it to $iface_vm, configure VM
        get_iface_vm
    
        local cmd=(
	    {iptables -F}
	    {ip6tables -F}
	    {setenforce 0}
	    {ip link set dev $iface_vm down}
	    {ip link set dev $iface_vm up}
	    {ip link set dev $iface_vm mtu $gre_vlan_mtu}
	    {ip addr flush dev $iface_vm}
	    {ip addr add $ip4addr_vm/24 dev $iface_vm}
	    {ip addr add $ip6addr_vm/64 dev $iface_vm}
	    {pkill netserver\; sleep 2\; netserver}
        )
        vmsh cmd_set $vm "${cmd[*]}"

        # add vnet to ovsbr and set vnet mtu
        ovs-vsctl add-port $ovsbr $vnet
        ip link set dev $vnet mtu $gre_vlan_mtu
    fi
    ip link set dev $iface mtu $mtu
    ip link set dev $intport mtu $gre_vlan_mtu
    ip link set dev $iface up
    ip link set dev $intport up
    ip addr add $ip4addr/24 dev $iface
    ip addr add $intport_ip4/24 dev $intport
    ip -6 addr add $intport_ip6/64 dev $intport
    sleep 10
    ip r
    echo -e " \n"
    ip -6 r
    ovs-vsctl show
}

# function to clean up entire environment before and after overall test run
cleanup_env()
{
	# echo "remove any bridge if exist"
	brctl show | sed -n 2~1p | awk '/^[[:alpha:]]/ { system("ip link set "$1" down; brctl delbr "$1) }'

	# echo "remove any ovs bridge if exist"
	ovs-vsctl list bridge | grep name | awk '{system("ovs-vsctl --if-exist del-br "$3)}'

	# echo "remove any vxlan if exist"
	ip -d link show | grep "\bvxlan\b" -B 2 | sed -n 1~3p | awk '{gsub(":",""); system ("ip link del "$2)}'

	# echo "remove any gre if exist"
	ip -d link show|grep "\bgretap\b" -B 2 | sed -n 1~3p | awk '($2 ~ /[[:alnum:]]+@[[:alnum:]]+/) {split($2,gre,"@"); system("ip link del "gre[1])}'

	# echo "remove any VM if exist"
	virsh list --all | sed -n 3~1p | awk '/[[:alpha:]]+/ { if ($3 == "running") { system("virsh shutdown "$2); sleep 2; system("virsh destroy "$2) }; system("virsh undefine --managed-save --snapshots-metadata --remove-all-storage "$2) }'
	# echo "remove any vnet definition if exist"
	virsh net-list --all | sed -n 3~1p | awk '/[[:alnum:]]+/ { system("virsh net-destroy "$1); sleep 2; system("virsh net-undefine "$1) }'

	#echo "remove any netns if exist"
	ip netns list | awk '{system("ip netns del "$1)}'
}

# function to cleanup environment between individual tests    
cleanup()
{
    ip link set dev $iface down
    ip address flush dev $iface
    ip link set dev $iface mtu 1500
    ovs-vsctl --if-exists del-br $ovsbr
    if [ $use_vm == yes ]; then
        ip link set dev $vnet mtu 1500
        vmsh run_cmd $vm "ip link set mtu 1500 dev $iface_vm"
        virsh shutdown $vm
    fi
    sleep 10
}    
    
#----------------------------------------------------------

# install necessary packages.  functions below are pulled from kernel/networking/impairment/install.sh
do_install()
{
    # epel repo
    epe_install

    # netperf
    netperf_install
    pkill netserver; sleep 2; netserver

    # sshpass
    sshpass_install

    # httpd
    httpd_install

    # ovs
    ovs_install

    #virtualization
    virt_install

    # install ip netns
    iproute2_install

    # brctl
    brctl_install
}

#----------------------------------------------------------

# set up env for ovs tests

setup_env()
{
    # stop security features
    iptables_stop_flush && setenforce 0

    # pull down netperf rpm for later scp to VMs
    #timeout 120s bash -c "until ping -c3 pkgs.repoforge.org; do sleep 10; done"
    #pushd /home; wget $pkg_netperf

    # VM related setup
    # pull down vm image and xml files to be used to create VM
    rm -f /tmp/$vm_xml_file /tmp/$vm.xml /var/lib/libvirt/images/$vm_image_name
    wget -O /var/lib/libvirt/images/$vm_image_name $vm_image_location/$vm_image_name 
    wget -O /tmp/$vm.xml $vm_image_location/$vm_xml_file
    sleep 10

    # define the vm using xml file downloaded
    virsh define /tmp/$vm.xml
}

#----------------------------------------------------------
# tests

# Host to Host tests

do_nic_test()
{
    local use_vm=no
    local result=0

    cleanup

    set_ipaddr_nic
 
    if i_am_client; then
        sync_wait server test_start

        log_header "netperf tests - Host to Host nic test  MTU: $mtu Driver: $iface_driver" $result_file
        $do_host_netperf $ip4addr,$ip4addr_peer $ip6addr,$ip6addr_peer $result_file,$tcp_threshold,$udp_threshold "" $netperf_time
        result=$?

        sync_set server test_end         
    else
        sync_set client test_start
        sync_wait client test_end
    fi
    
    cleanup

    return $result
}

do_ovs_nic_test()
{
    local use_vm=no
    local result=0

    cleanup

    ovs_nic_cfg
 
    if i_am_client; then
        sync_wait server test_start

        log_header "netperf tests - Host to Host ovs nic test (without VLAN) MTU: $mtu Driver: $iface_driver" $result_file
        $do_host_netperf $ip4addr,$ip4addr_peer $ip6addr,$ip6addr_peer $result_file,$tcp_threshold,$udp_threshold  "" $netperf_time
        result=$?

        sync_set server test_end         
    else
        sync_set client test_start
        sync_wait client test_end
    fi

    cleanup

    return $result
}

do_ovs_test()
{
    local use_vm=no
    local result=0

    cleanup

    ovs_cfg
 
    if i_am_client; then
        sync_wait server test_start

        log_header "netperf tests - Host to Host ovs internal port test (without VLAN) MTU: $mtu Driver: $iface_driver" $result_file
        $do_host_netperf $intport_ip4,$intport_ip4_peer $intport_ip6,$intport_ip6_peer $result_file,$tcp_threshold,$udp_threshold  "" $netperf_time
        result=$?

        sync_set server test_end         
    else
        sync_set client test_start
        sync_wait client test_end
    fi

    cleanup

    return $result
}

do_ovs_vlan_test()
{
    local use_vm=no
    local result=0

    cleanup

    ovs_vlan_cfg
 
    if i_am_client; then
        sync_wait server test_start

        log_header "netperf tests - Host to Host ovs internal port test (with VLAN) MTU: $mtu Driver: $iface_driver" $result_file
        $do_host_netperf $intport_ip4,$intport_ip4_peer $intport_ip6,$intport_ip6_peer $result_file,$tcp_threshold,$udp_threshold  "" $netperf_time
        result=$?

        sync_set server test_end         
    else
        sync_set client test_start
        sync_wait client test_end
    fi

    cleanup

    return $result
}

do_ovs_vxlan_test()
{
    local use_vm=no
    local use_vxlan="yes"
    local result=0

    cleanup

    ovs_vxlan_cfg
 
    if i_am_client; then
        sync_wait server test_start

        log_header "netperf tests - Host to Host ovs vxlan test (without VLAN) MTU: $mtu Driver: $iface_driver" $result_file
        $do_host_netperf $intport_ip4,$intport_ip4_peer $intport_ip6,$intport_ip6_peer $result_file,$tunnel_tcp_threshold,$tunnel_udp_threshold  "" $netperf_time
        result=$?

        sync_set server test_end         
    else
        sync_set client test_start
        sync_wait client test_end
    fi

    cleanup

    return $result
}

do_ovs_vxlan_vlan_test()
{
    local use_vm=no
    local use_vxlan_vlan="yes"
    local result=0

    cleanup

    ovs_vxlan_vlan_cfg
 
    if i_am_client; then
        sync_wait server test_start

        log_header "netperf tests - Host to Host ovs vxlan test (with VLAN) MTU: $mtu Driver: $iface_driver" $result_file
        $do_host_netperf $intport_ip4,$intport_ip4_peer $intport_ip6,$intport_ip6_peer $result_file,$tunnel_tcp_threshold,$tunnel_udp_threshold  "" $netperf_time
        result=$?

        sync_set server test_end         
    else
        sync_set client test_start
        sync_wait client test_end
    fi

    cleanup

    return $result
}

do_ovs_gre_test()
{
    local use_vm=no
    local use_gre="yes"
    local result=0
 
    cleanup

    ovs_gre_cfg
 
    if i_am_client; then
        sync_wait server test_start

        log_header "netperf tests - Host to Host ovs gre test (without VLAN) MTU: $mtu Driver: $iface_driver" $result_file
        $do_host_netperf $intport_ip4,$intport_ip4_peer $intport_ip6,$intport_ip6_peer $result_file,$tunnel_tcp_threshold,$tunnel_udp_threshold  "" $netperf_time
        result=$?

        sync_set server test_end         
    else
        sync_set client test_start
        sync_wait client test_end
    fi

    cleanup

    return $result
}

do_ovs_gre_vlan_test()
{
    local use_vm=no
    local use_gre_vlan="yes"
    local result=0
 
    cleanup

    ovs_gre_vlan_cfg
 
    if i_am_client; then
        sync_wait server test_start

        log_header "netperf tests - Host to Host ovs gre test (with VLAN) MTU: $mtu Driver: $iface_driver" $result_file
        $do_host_netperf $intport_ip4,$intport_ip4_peer $intport_ip6,$intport_ip6_peer $result_file,$tunnel_tcp_threshold,$tunnel_udp_threshold  "" $netperf_time
        result=$?

        sync_set server test_end         
    else
        sync_set client test_start
        sync_wait client test_end
    fi

    cleanup

    return $result
}

# VM to VM tests

do_ovs_vm_nic_test()
{
    local use_vm=yes
    local result=0

    cleanup

    ovs_nic_cfg
 
    if i_am_client; then
        sync_wait server test_start

        log_header "netperf tests - VM to VM ovs nic test (without VLAN) MTU: $mtu Driver: $iface_driver" $result_file
        $do_vm_netperf $vm $ip4addr_vm,$ip4addr_vm_peer $ip6addr_vm,$ip6addr_vm_peer $result_file,$tcp_threshold,$udp_threshold  "" $netperf_time
        result=$?

        sync_set server test_end         
    else
        sync_set client test_start
        sync_wait client test_end
    fi

    cleanup

    return $result
}

do_ovs_vm_test()
{
    local use_vm=yes
    local result=0

    cleanup

    ovs_cfg
 
    if i_am_client; then
        sync_wait server test_start

        log_header "netperf tests - VM to VM ovs internal port test (without VLAN) MTU: $mtu Driver: $iface_driver" $result_file
        $do_vm_netperf $vm $ip4addr_vm,$ip4addr_vm_peer $ip6addr_vm,$ip6addr_vm_peer $result_file,$tcp_threshold,$udp_threshold  "" $netperf_time
        result=$?

        sync_set server test_end         
    else
        sync_set client test_start
        sync_wait client test_end
    fi

    cleanup

    return $result
}

do_ovs_vm_vlan_test()
{
    local use_vm=yes
    local result=0

    cleanup

    ovs_vlan_cfg
 
    if i_am_client; then
        sync_wait server test_start

        log_header "netperf tests - VM to VM ovs internal port test (with VLAN) MTU: $mtu Driver: $iface_driver" $result_file
        $do_vm_netperf $vm $ip4addr_vm,$ip4addr_vm_peer $ip6addr_vm,$ip6addr_vm_peer $result_file,$tcp_threshold,$udp_threshold  "" $netperf_time
        result=$?

        sync_set server test_end         
    else
        sync_set client test_start
        sync_wait client test_end
    fi

    cleanup

    return $result
}

do_ovs_vm_vxlan_test()
{
    local use_vm=yes
    local use_vxlan="yes"
    local result=0

    cleanup

    ovs_vxlan_cfg
 
    if i_am_client; then
        sync_wait server test_start

        log_header "netperf tests - VM to VM ovs vxlan test (without VLAN) MTU: $mtu Driver: $iface_driver" $result_file
        $do_vm_netperf $vm $ip4addr_vm,$ip4addr_vm_peer $ip6addr_vm,$ip6addr_vm_peer $result_file,$tunnel_tcp_threshold,$tunnel_udp_threshold  "" $netperf_time
        result=$?

        sync_set server test_end         
    else
        sync_set client test_start
        sync_wait client test_end
    fi

    cleanup

    return $result
}

do_ovs_vm_vxlan_vlan_test()
{
    local use_vm=yes
    local use_vxlan_vlan="yes"
    local result=0

    cleanup

    ovs_vxlan_vlan_cfg
 
    if i_am_client; then
        sync_wait server test_start

        log_header "netperf tests - VM to VM ovs vxlan test (with VLAN) MTU: $mtu Driver: $iface_driver" $result_file
        $do_vm_netperf $vm $ip4addr_vm,$ip4addr_vm_peer $ip6addr_vm,$ip6addr_vm_peer $result_file,$tunnel_tcp_threshold,$tunnel_udp_threshold  "" $netperf_time
        result=$?

        sync_set server test_end         
    else
        sync_set client test_start
        sync_wait client test_end
    fi

    cleanup

    return $result
}

do_ovs_vm_gre_test()
{
    local use_vm=yes
    local use_gre="yes"
    local result=0

    cleanup

    ovs_gre_cfg
 
    if i_am_client; then
        sync_wait server test_start

        log_header "netperf tests - VM to VM ovs nic test (without VLAN) MTU: $mtu Driver: $iface_driver" $result_file
        $do_vm_netperf $vm $ip4addr_vm,$ip4addr_vm_peer $ip6addr_vm,$ip6addr_vm_peer $result_file,$tunnel_tcp_threshold,$tunnel_udp_threshold  "" $netperf_time
        result=$?

        sync_set server test_end         
    else
        sync_set client test_start
        sync_wait client test_end
    fi

    cleanup

    return $result
}

do_ovs_vm_gre_vlan_test()
{
    local use_vm=yes
    local use_gre_vlan="yes"
    local result=0

    cleanup

    ovs_gre_vlan_cfg
 
    if i_am_client; then
        sync_wait server test_start

        log_header "netperf tests - VM to VM ovs gre test (with VLAN) MTU: $mtu Driver: $iface_driver" $result_file
        $do_vm_netperf $vm $ip4addr_vm,$ip4addr_vm_peer $ip6addr_vm,$ip6addr_vm_peer $result_file,$tunnel_tcp_threshold,$tunnel_udp_threshold  "" $netperf_time
        result=$?

        sync_set server test_end         
    else
        sync_set client test_start
        sync_wait client test_end
    fi

    cleanup

    return $result
}

# function to check logs for basic problems after each test
do_check_logs()
{
        local result=0

        if egrep -iq '/oops/|segmentation|lockup' /var/log/messages; then
            return 1
        fi

        if i_am_client; then
                rhts_submit_log -l $result_file
        fi

        return $result
}

# main

rlJournalStart
if [ -z "$JOBID" ]; then
        echo "Variable jobid not set! Assume developer mode."
        CLIENTS="netqe2.knqe.lab.eng.bos.redhat.com"
        SERVERS="netqe4.knqe.lab.eng.bos.redhat.com"
fi
echo "Client : $CLIENTS"
echo "Server : $SERVERS"

    rlPhaseStartSetup
        # clean up overall environment
        rlRun "cleanup_env"

        # install required packages
        rlRun "do_install"

        if i_am_client; then
            echo "OVS_TEST_RESULTS ($iface):    $(date)" > $result_file
            echo "kernel: $(uname -r)" >> $result_file
            echo "CLIENTS: $CLIENTS" >> $result_file
            echo "SERVERS: $SERVERS" >> $result_file
            echo ""
        fi

        # finish setting up environment    
        rlRun setup_env
    rlPhaseEnd

if [ -z "$OVS_TOPO" ] || echo $OVS_TOPO | grep -q -E "(ovs_all|nic\b)"; then
    rlPhaseStartTest "Run NIC to NIC host to host tests"
        rlRun "do_nic_test"
    rlPhaseEnd
fi

rlPhaseStartTest "Check for problems in /var/log/messages"
        rlRun "do_check_logs"
rlPhaseEnd

if [ -z "$OVS_TOPO" ] || echo $OVS_TOPO | grep -q -E "(ovs_all|ovs_nic\b)"; then
    rlPhaseStartTest "Run OVS NIC host to host tests"
        rlRun "do_ovs_nic_test"
    rlPhaseEnd
fi

rlPhaseStartTest "Check for problems in /var/log/messages"
        rlRun "do_check_logs"
rlPhaseEnd

if [ -z "$OVS_TOPO" ] || echo $OVS_TOPO | grep -q -E "(ovs_all|ovs_no_vlan\b)"; then
    rlPhaseStartTest "Run OVS internal port host to host tests (no VLAN)"
        rlRun "do_ovs_test"
    rlPhaseEnd
fi

rlPhaseStartTest "Check for problems in /var/log/messages"
        rlRun "do_check_logs"
rlPhaseEnd

if [ -z "$OVS_TOPO" ] || echo $OVS_TOPO | grep -q -E "(ovs_all|ovs_vlan\b)"; then
    rlPhaseStartTest "Run OVS internal port host to host tests (VLAN)"
        rlRun "do_ovs_vlan_test"
    rlPhaseEnd
fi

rlPhaseStartTest "Check for problems in /var/log/messages"
        rlRun "do_check_logs"
rlPhaseEnd

if [ -z "$OVS_TOPO" ] || echo $OVS_TOPO | grep -q -E "(ovs_all|ovs_vxlan\b)"; then
    rlPhaseStartTest "Run OVS VXLAN tunnel host to host tests (no VLAN)"
        rlRun "do_ovs_vxlan_test"
    rlPhaseEnd
fi

rlPhaseStartTest "Check for problems in /var/log/messages"
        rlRun "do_check_logs"
rlPhaseEnd

if [ -z "$OVS_TOPO" ] || echo $OVS_TOPO | grep -q -E "(ovs_all|ovs_vxlan_vlan\b)"; then
    rlPhaseStartTest "Run OVS VXLAN tunnel host to host tests (VLAN)"
        rlRun "do_ovs_vxlan_vlan_test"
    rlPhaseEnd
fi

rlPhaseStartTest "Check for problems in /var/log/messages"
        rlRun "do_check_logs"
rlPhaseEnd

if [ -z "$OVS_TOPO" ] || echo $OVS_TOPO | grep -q -E "(ovs_all|ovs_gre\b)"; then
    rlPhaseStartTest "Run OVS GRE tunnel host to host tests (no VLAN)"
        rlRun "do_ovs_gre_test"
    rlPhaseEnd
fi

rlPhaseStartTest "Check for problems in /var/log/messages"
        rlRun "do_check_logs"
rlPhaseEnd

if [ -z "$OVS_TOPO" ] || echo $OVS_TOPO | grep -q -E "(ovs_all|ovs_gre_vlan\b)"; then
rlPhaseStartTest "Run OVS GRE tunnel host to host tests (VLAN)"
        rlRun "do_ovs_gre_vlan_test"
rlPhaseEnd
fi

rlPhaseStartTest "Check for problems in /var/log/messages"
        rlRun "do_check_logs"
rlPhaseEnd

if [ -z "$OVS_TOPO" ] || echo $OVS_TOPO | grep -q -E "(ovs_all|ovs_vm_nic\b)"; then
    rlPhaseStartTest "Run OVS NIC vm to vm tests"
        rlRun "do_ovs_vm_nic_test"
    rlPhaseEnd
fi

rlPhaseStartTest "Check for problems in /var/log/messages"
        rlRun "do_check_logs"
rlPhaseEnd

if [ -z "$OVS_TOPO" ] || echo $OVS_TOPO | grep -q -E "(ovs_all|ovs_vm\b)"; then
    rlPhaseStartTest "Run OVS internal port vm to vm tests (no VLAN)"
        rlRun "do_ovs_vm_test"
    rlPhaseEnd
fi

rlPhaseStartTest "Check for problems in /var/log/messages"
        rlRun "do_check_logs"
rlPhaseEnd

if [ -z "$OVS_TOPO" ] || echo $OVS_TOPO | grep -q -E "(ovs_all|ovs_vm_vlan\b)"; then
    rlPhaseStartTest "Run OVS internal port vm to vm tests (VLAN)"
        rlRun "do_ovs_vm_vlan_test"
    rlPhaseEnd
fi

rlPhaseStartTest "Check for problems in /var/log/messages"
        rlRun "do_check_logs"
rlPhaseEnd

if [ -z "$OVS_TOPO" ] || echo $OVS_TOPO | grep -q -E "(ovs_all|ovs_vm_vxlan\b)"; then
    rlPhaseStartTest "Run OVS vxlan vm to vm tests (no VLAN)"
        rlRun "do_ovs_vm_vxlan_test"
    rlPhaseEnd
fi

rlPhaseStartTest "Check for problems in /var/log/messages"
        rlRun "do_check_logs"
rlPhaseEnd

if [ -z "$OVS_TOPO" ] || echo $OVS_TOPO | grep -q -E "(ovs_all|ovs_vm_vxlan_vlan\b)"; then
    rlPhaseStartTest "Run OVS vxlan vm to vm tests (VLAN)"
        rlRun "do_ovs_vm_vxlan_vlan_test"
    rlPhaseEnd
fi

rlPhaseStartTest "Check for problems in /var/log/messages"
        rlRun "do_check_logs"
rlPhaseEnd

if [ -z "$OVS_TOPO" ] || echo $OVS_TOPO | grep -q -E "(ovs_all|ovs_vm_gre\b)"; then
    rlPhaseStartTest "Run OVS gre vm to vm tests (no VLAN)"
        rlRun "do_ovs_vm_gre_test"
    rlPhaseEnd
fi

rlPhaseStartTest "Check for problems in /var/log/messages"
        rlRun "do_check_logs"
rlPhaseEnd

if [ -z "$OVS_TOPO" ] || echo $OVS_TOPO | grep -q -E "(ovs_all|ovs_vm_gre_vlan\b)"; then
    rlPhaseStartTest "Run OVS gre vm to vm tests (VLAN)"
        rlRun "do_ovs_vm_gre_vlan_test"
    rlPhaseEnd
fi

rlPhaseStartTest "Check for problems in /var/log/messages"
        rlRun "do_check_logs"
rlPhaseEnd

rlPhaseStartTest "Clean up the overall environment at end of all tests"
rlRun "cleanup_env"
rlPhaseEnd

if i_am_client; then
    rhts_submit_log -l $result_file
fi
rlJournalPrintText
rlJournalEnd
