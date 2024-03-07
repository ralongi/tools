#!/bin/bash
# vim: dict=/usr/share/beakerlib/dictionary.vim cpt=.,w,b,u,t,i,k sts=4 sw=4 et
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   runtest.sh of /kernel/networking/openvswitch/tests/mcast_snoop
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
dbg_flag=${dbg_flag:-"set -x"}
$dbg_flag

# variables
PACKAGE="kernel"

# include Beaker environment
. /mnt/tests/kernel/networking/common/include.sh || exit 1
 
# include common install functions
. /mnt/tests/kernel/networking/common/install.sh || exit 1

# include common networking functions
. /mnt/tests/kernel/networking/common/network.sh || exit 1
. /mnt/tests/kernel/networking/common/lib/lib_nc_sync.sh || exit 1

#pull down git repo
mkdir /mnt/git_repo
cd /mnt/git_repo && git clone git://pkgs.devel.redhat.com/tests/kernel

# include private common functions
. /mnt/git_repo/kernel/networking/impairment/networking_common.sh || exit 1
. /mnt/git_repo/kernel/networking/impairment/install.sh || exit 1
. /mnt/git_repo/kernel/networking/openvswitch/tests/perf_check/lib_netperf_all.sh || exit 1

# set default password to be used for tests 
password="100yard-"

# rhel version
rhel_version=$(cut -f1 -d. /etc/redhat-release | sed 's/[^0-9]//g')

# check for installation of NetworkManager and install if necessary, enable and start service which was likley stopped by the common functions above
networkmanager_install

# pointer to log file
result_file=${result_file:-"ovs_mcast_snoop_test_result.log"}

vm1=${vm1:-"g1"}
vm2=${vm2:-"g2"}
vm3=${vm3:-"g3"}
vm_list1=$(echo $vm1 $vm2 $vm3)
vm_list2=$(echo $vm2 $vm3)
vm_list3=$(echo $vm1 $vm2 $vm3)
vm_image_name=${vm_image_name:-""}
vm_image_location=${vm_image_location:-"http://netqe-infra01.knqe.eng.rdu2.dc.redhat.com"}
vm_xml_file=${vm_xml_file:-""}

if [ -z "$JOBID" ]; then
	ipaddr=120
else
	ipaddr=$((JOBID % 100 + 20))
fi

ip4addr=192.168.$((ipaddr + 0)).2
ip6addr=2014:$((ipaddr + 0))::2
ip4addr_vm_base=192.168.$((ipaddr + 50))
ip6addr_vm_base=2015:$((ipaddr + 50))
intport_ip4=192.168.$((ipaddr + 100)).2
intport_ip6=2016:$((ipaddr + 100))::2
con_name="static-$iface"
ovsbr="myovs"
intport="intport0"
mtu=${mtu:-"1500"}

# specify ovs rpm/version to be used
if (($rhel_version <= 6)); then
    openvswitch_rpm=${openvswitch_rpm:-"http://download.eng.bos.redhat.com/brewroot/packages/openvswitch/2.3.0/1.el6/x86_64/openvswitch-2.3.0-1.el6.x86_64.rpm"}
else 
    openvswitch_rpm=${openvswitch_rpm:-"http://download.eng.bos.redhat.com/brewroot/packages/openvswitch/2.4.0/1.el7/x86_64/openvswitch-2.4.0-1.el7.x86_64.rpm"}
fi

iperf_rpm=${iperf_rpm:-"iperf-2.0.4-1.el7.rf.x86_64.rpm"}
iperf_location=${iperf_location:-"http://netqe-infra01.knqe.eng.rdu2.dc.redhat.com"}

vm_tmp_result_file="/tmp/vm_tmp_result.tmp"

#############################################################################

# function to install necessary packages
do_install()
{
    # epel repo
    epe_install

    # dos2unix
    yum -y install dos2unix

    # ovs
    ovs_install

    #virtualization
    virt_install

    # brctl
    brctl_install

    # httpd
    httpd_install
}

# function to obtain interface being used on VM and set it to $iface_vm
get_iface_vm()
{
    local tmp_file="/tmp/ip_a.tmp"
    target_vm=$1
    vmsh run_cmd $target_vm "ip l l" 2>&1 | tee $tmp_file
    iface_vm=$(grep BROADCAST $tmp_file | awk '{ print $2 }'| awk -F ":" '{ print $1 }')
    echo "The interface on $target_vm is: $iface_vm"
}

# function to update kernel on the VM
update_kernel_vm()
{
    target_vm=$1
    vmsh run_cmd $target_vm "uname -r" 2>&1 | tee vm_k_ver.txt
    dos2unix -f vm_k_ver.txt
	host_k_ver=$(uname -r)
	vm_k_ver=$(awk '/uname -r/{getline; print}' vm_k_ver.txt)
    rm -f vm_k_ver.txt
        
	if [[ "$host_k_ver" == "$vm_k_ver" ]]; then
        echo "Kernel versions match."
        return 0
    else
    	local intport_ip4_tmp=$(echo $ip4addr_vm_base".41")
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
	
        ip a | grep $intport | grep "$intport_ip4_tmp"
        if [[ $? != 0 ]]; then
            ip addr add $intport_ip4_tmp/24 dev $intport
        fi
        cd /var/www/html; rm -f *rpm*
	    wget -nv http://download.eng.bos.redhat.com/brewroot/packages/kernel/$v1/$v2/$p/$host_kernel_rpm
    fi

	vmsh run_cmd $target_vm "rpm -ivh --nodeps --force http://"$intport_ip4_tmp"/$host_kernel_rpm"
	virsh reboot $target_vm

	sleep 60
}

# set up environment for tests

setup_env()
{
    # install necessary packages
    do_install
    
    # make sure SELInux is enabled to check for BZ1262357.  may not be possible to enable in DPDK scenario.
    selinux_setting=$(getenforce)
    if [[ $selinux_setting != "Enforcing" ]]; then setenforce 1; getenforce; fi

    # VM related setup
    # pull down vm image and xml files to be used to create VM
    rm -f /tmp/$vm_xml_file /var/lib/libvirt/images/$vm_image_name
    wget -nv -O /var/lib/libvirt/images/$vm_image_name $vm_image_location/$vm_image_name 
    wget -nv -O /tmp/$vm1.xml $vm_image_location/$vm_xml_file
    wget -nv -O /tmp/$vm2.xml $vm_image_location/$vm_xml_file && sed -i "s/$vm1/$vm2/g" /tmp/"$vm2".xml
    wget -nv -O /tmp/$vm3.xml $vm_image_location/$vm_xml_file && sed -i "s/$vm1/$vm3/g" /tmp/"$vm3".xml
    sleep 10

    # create OVS bridge to support subsequent VM creation
    local intport_ip4_tmp=$(echo $ip4addr_vm_base".41")
    ovs-vsctl --if-exists del-br $ovsbr
    ovs-vsctl add-br $ovsbr
    ovs-vsctl add-port $ovsbr $intport -- set interface $intport type=internal
    ip a | grep $intport | grep "$intport_ip4_tmp"
    if [[ $? != 0 ]]; then
        ip addr add $intport_ip4_tmp/24 dev $intport
    fi
    ip link set dev $intport up
    sleep 10; ip a | grep -A1 $intport; ip r    

    # define the VMs using xml files downloaded
    for i in $vm_list1; do
        virsh define /tmp/$i.xml; sleep 2
    done

    # start the VMs
    #for i in $vm_list1; do
    #    virsh start $i; sleep 90
    #done

    # restart $vm1 to work around disk I/O error
    #virsh destroy $vm1; sleep 5; virsh start $vm1; sleep 45
    #for i in $vmlist3; do
    #    virsh destroy $i; sleep 5; virsh start $i; sleep 90
    #done

    # set static IP addresses so they will persist across reboots
    # shutdown all VMs and set config one at a time to avoind console hang problems
    #vm_running=$(virsh list --all | grep running | awk '{ print $1 }')
    #for i in $vm_running; do virsh destroy $i; done
    for i in $vm_list1; do

        last_octet=$(echo $i | tr -d g)        
        virsh start $i && sleep 45 

        # get interface to be used on vms, set it to $iface_vm
        get_iface_vm $i

        # set static IP addresses using method based on version of RHEL
        vmsh run_cmd $i "cat /etc/redhat-release" > vm_rhel.txt
        local vm_rhel_version=$(grep -A1 "redhat-release" vm_rhel.txt | grep "Red Hat" | cut -f1 -d. | sed 's/[^0-9]//g')
        local vm_con_name="static-$iface_vm"
        local ifcfg_file="ifcfg-$iface_vm"
        local vm_hwaddr=$(vmsh run_cmd $i "ip l l" > link.txt; grep -A1 $iface_vm link.txt | awk '{getline; print $2}')

        if [[ $vm_rhel_version -ge 7 ]]; then
            local cmd=(
            {iptables -F}
	        {ip6tables -F}
            {nmcli con del $vm_con_name}
	        {nmcli con add con-name $vm_con_name ifname $iface_vm type ethernet ip4 $ip4addr_vm_base.$last_octet/24 ip6 $ip6addr_vm_base::$last_octet/64}
            {nmcli con mod $vm_con_name 802-3-ethernet.mtu $mtu}
	        {nmcli con up $vm_con_name}
            {sleep 5}
            {ip a}
            {ip r}
            {ip -6 r}
            )
        else
            vmsh run_cmd $i "ip link set dev $iface_vm up; ip addr flush dev $iface_vm; ip addr add $ip4addr_vm/24 dev $iface_vm; ip a; ip r"
            sleep 3
            vmsh run_cmd $i "timeout 30s bash -c \"until ping -c3 $intport_ip4_tmp; do sleep 10; done\""
            rm -f /var/www/html/$ifcfg_file
            (
		        echo "DEVICE=$iface_vm"
		        echo "HWADDR=$vm_hwaddr"
		        echo "Type=Ethernet"
		        echo "ONBOOT=yes"
		        echo "NM_CONTROLLED=no"
		        echo "BOOTPROTO=none"
		        echo IPADDR=$ip4addr_$i
		        echo "NETMASK=255.255.255.0"
		        echo IPV6INIT=yes
		        echo IPV6ADDR=$ip6addr_$i/64
		        echo MTU=$mtu
	        )   > /var/www/html/$ifcfg_file
            local cmd=(
	        {iptables -F}
	        {ip6tables -F}
	        {ip a}
	        {ip r}
            {ip -6 r}
	        {cd /etc/sysconfig/network-scripts}
            {rm -f $ifcfg_file}
            {wget -nv http://$intport_ip4_tmp/$ifcfg_file}
            {ifdown $iface_vm}
            {ifup $iface_vm}
            {sleep 5}
	        {ip a}
	        {ip r}
	        {ip -6 r}
            )       
        fi   
        vmsh cmd_set $i "${cmd[*]}"
        sleep 3; virsh destroy $i; sleep 3
    done

    # update kernel on the VMs
    for i in $vm_list1; do
        virsh start $i && sleep 45
        update_kernel_vm $i
 
        local cmd=(
        {uname -r}
        {iptables -F}
        {ip6tables -F}
        {ip a}
        {ip r}
        {ip -6 r}
        )
        vmsh cmd_set $i "${cmd[*]}"
        sleep 3; virsh destroy $i; sleep 3
    done

    # flush temporary intport IP address
    ip a | grep $intport | grep "$intport_ip4_tmp"
    if [[ $? == 0 ]]; then
        ip addr del $intport_ip4_tmp/24 dev $intport
    fi

    #for i in $vm_list1; do virsh start $i; done
    #sleep 60    
}

# clean up the environment before and after tests
cleanup_env()
{
	# echo "remove any Linux bridges if they exist"
	brctl show | sed -n 2~1p | awk '/^[[:alpha:]]/ { system("ip link set "$1" down; brctl delbr "$1) }'

	# echo "remove any OVS bridges if they exist"
	ovs-vsctl list bridge | grep name | awk '{system("ovs-vsctl --if-exist del-br "$3)}'

	# echo "remove any VxLANs if exist"
	ip -d link show | grep "\bvxlan\b" -B 2 | sed -n 1~3p | awk '{gsub(":",""); system ("ip link del "$2)}'

	# echo "remove any gre if they exist"
	ip -d link show|grep "\bgretap\b" -B 2 | sed -n 1~3p | awk '($2 ~ /[[:alnum:]]+@[[:alnum:]]+/) {split($2,gre,"@"); system("ip link del "gre[1])}'

	# echo "remove any VMs if they exist"
	virsh list --all | sed -n 3~1p | awk '/[[:alpha:]]+/ { if ($3 == "running") { system("virsh shutdown "$2); sleep 2; system("virsh destroy "$2) }; system("virsh undefine --managed-save --snapshots-metadata --remove-all-storage "$2) }'
	# echo "remove any vnet definitions if they exist"
	virsh net-list --all | sed -n 3~1p | awk '/[[:alnum:]]+/ { system("virsh net-destroy "$1); sleep 2; system("virsh net-undefine "$1) }'

	#echo "remove any netns if they exist"
	ip netns list | awk '{system("ip netns del "$1)}'

    # echo "remove any veth links if they exist"
    veths=$(ip link | grep veth | awk '{ print $2 }' | awk -F @ '{ print $1 }')
    for i in $veths; do ip link del $i | true; done

	# echo "delete the static connection via nmcli"
    nmcli con show | grep $con_name
    if [[ $? == 0 ]]; then nmcli con del $con_name; fi

    # echo "delete all files from /tmp"
    rm -f /tmp/*
}

#----------------------------------------------------------

# function to check result of previous command on a vm
check_result_vm()
{
    local result=0
    local file_name=$1

    dos2unix -f $file_name
    vm_result=$(grep -A1 'echo $?' $file_name | grep -v 'echo $?')
    if [[ $vm_result != 0 ]]; then 
        echo "The previous command failed."
            return $vm_result
    else
        echo "The previous command was successful."
            return $vm_result
    fi

    return $result  

}    

# define the tests

# verify that the mcast route can be added successfully to all VMs
add_mcast_route_test()
{
    local result=0
    for i in $vm_list1; do
        virsh start $i; sleep 45
        vmsh run_cmd $i "/sbin/route -n add -net 224.0.0.0 netmask 240.0.0.0 dev $iface_vm"
        vmsh run_cmd $i "sleep 2; /sbin/route -n | grep 224"  2>&1 | tee $vm_tmp_result_file
        check_result_vm $vm_tmp_result_file
        virsh destroy $i; sleep 3
    done
}


    # add the necessary route to routing table, confirm it was added successfully
    #for i in $vm_list1; do
     #   local cmd=(
      #  {/sbin/route -n add -net 224.0.0.0 netmask 240.0.0.0 dev "$iface_vm"}
       # {if [[ $? != 0 ]]; then echo "mcast route addition failed on $i"; else echo "mcast route addition was successful on $i"; fi}
        #{/sbin/route -n | grep 224}
        #{#if [[ $? != 0 ]]; then echo "mcast route addition failed on $i"; else echo "mcast route addition was successful on $i"; fi}
        #)
        #vmsh cmd_set $i "${cmd[*]}"
    #done

# verify correct behavior when ovs mcast snooping is enabled
mcast_snoop_disabled_test()
{
    local result=0

    # make sure ovs mcast snooping is disabled
    ovs-vsctl set Bridge $ovsbr mcast_snooping_enable=false
    if [[ $? != 0 ]]; then echo "attempt to disable mcast snooping failed"; fi

    # start all VMs
    #for i in $vm_list1; do virsh start $i; sleep 45; done

    # launch iperf as a mcast server on $vm1
    virsh start $vm1
    vmsh run_cmd $vm1 "iperf -s -u -B 224.0.55.55 -i 1 -p $iface_vm &"

    # verify that mcast packets are being seen by $vm2 and $vm3
    
    for i in $vm_list2; do
        virsh start $i
        vmsh run_cmd $i "timeout 10s bash -c tcpdump -nn -i $iface_vm ip multicast; sleep 3" 2>&1 | tee /tmp/tcpdump_output1.asc
        grep 224 /tmp/tcpdump_output1.asc  2>&1 | tee $vm_tmp_result_file
        check_result_vm $vm_tmp_result_file
        virsh destroy $i; sleep 3

        #local cmd=(
        #{timeout 10s bash -c "until tcpdump -nn -i $iface_vm ip multicast; do sleep 10; done" > /tmp/tcpdump_output1.asc}
        #{grep "224" /tmp/tcpdump_output1.asc}
        #{if [[ $? != 0 ]]; then echo "NO MCAST PACKETS ARE BEING TRANSMITTED!  TEST FAILED!"; else echo "MCAST PACKETS ARE BEING TRANSMITTED!  TEST PASSED!"; fi}
        #)
        #vmsh cmd_set $i "${cmd[*]}"
    done

    return $result
}

# verify correct behavior when mcast snooping is enabled
mcast_snoop_enabled_test()
{
    local result=0

    # kill the iperf server on $vm1
    vmsh run_cmd $vm1 "pkill iperf"
    #local cmd=(
    #{pkill iperf}
    #{if [[ $? != 0 ]]; then echo "iperf process was NOT successfully killed"; else echo "iperf process was not successfully killed"; fi}
    #)
    #vmsh cmd_set $vm1 "${cmd[*]}"

    # enable ovs mcast snooping
    ovs-vsctl set Bridge $ovsbr mcast_snooping_enable=true
    if [[ $? != 0 ]]; then echo "Attempt to enable mcast snooping failed"; else echo "Attempt to enable mcast snooping was successful"; fi

    # launch iperf mcast server on $vm1
    vmsh run_cmd $vm1 "iperf -s -u -B 224.0.55.55 -i 1 -p $iface_vm &"
    #local cmd=(
    #{iperf -s -u -B 224.0.55.55 -i 1 -p "$iface_vm"}
    #)
    #vmsh cmd_set $vm1 "${cmd[*]}"

    # verify that NO mcast packets are seen by $vm2 or $vm3
    for i in $vm_list2; do
        virsh start $i
        vmsh run_cmd $i "timeout 10s bash -c tcpdump -nn -i $iface_vm ip multicast; sleep 3" 2>&1 | tee /tmp/tcpdump_output2.asc
        grep 224 /tmp/tcpdump_output2.asc  2>&1 | tee $vm_tmp_result_file
        check_result_vm $vm_tmp_result_file
        virsh destroy $i
        #local cmd=(
        #{timeout 10s bash -c "until tcpdump -nn -i $iface_vm ip multicast; do sleep 10; done" > /tmp/tcpdump_output2.asc}
        #{grep "224" /tmp/tcpdump_output2.asc}
        #{if [[ $? == 0 ]]; then echo "MCAST PACKETS ARE BEING TRANSMITTED!  TEST FAILED!"; else echo "NO MCAST PACKETS ARE BEING TRANSMITTED!  TEST PASSED!"; fi}
        #)
        #vmsh cmd_set $i "${cmd[*]}"
    done

    # launch iperf mcast client on $vm2 and $vm3, verify that mcast packets are now seen by $vm2 and $vm3
    for i in $vm_list2; do
        virsh start $i
        vmsh run_cmd $i "iperf -c 224.0.55.55 -u -T 32 -t 3 -i 1 -p $iface_vm; sleep 10"
        vmsh run_cmd $i "timeout 10s bash -c tcpdump -nn -i $iface_vm ip multicast; sleep 3" 2>&1 | tee /tmp/tcpdump_output3.asc
        grep 224 /tmp/tcpdump_output3.asc  2>&1 | tee $vm_tmp_result_file
        check_result_vm $vm_tmp_result_file
        virsh destroy $i
        #local cmd=(
        #{iperf -c 224.0.55.55 -u -T 32 -t 3 -i 1 -p "$iface_vm"}
        #{sleep 10}
        #{timeout 10s bash -c "until tcpdump -nn -i $iface_vm ip multicast; do sleep 10; done" > /tmp/tcpdump_output3.asc}
        #{grep "224" /tmp/tcpdump_output3.asc}
        #{if [[ $? != 0 ]]; then echo "NO MCAST PACKETS ARE BEING TRANSMITTED!  TEST FAILED!"; else echo "MCAST PACKETS ARE BEING TRANSMITTED!  TEST PASSED!"; fi}
        #)
        #vmsh cmd_set $i "${cmd[*]}"
    done

    # verify that mcast packets are seen by $vm1
    #vmsh run_cmd $vm1 "timeout 10s bash -c until tcpdump -nn -i $iface_vm ip multicast; do sleep 10; done" 2>&1 | tee /tmp/tcpdump_output4.asc
    #vmsh run_cmd $vm1 "grep 224 /tmp/tcpdump_output4.asc"  2>&1 | tee $vm_tmp_result_file
    #check_result_vm $vm_tmp_result_file
    #local cmd=(
    #{timeout 10s bash -c "until tcpdump -nn -i $iface_vm ip multicast; do sleep 10; done" > /tmp/tcpdump_output4.asc}
    #{grep "224" /tmp/tcpdump_output4.asc}
    #{if [[ $? != 0 ]]; then echo "NO MCAST PACKETS ARE BEING TRANSMITTED!  TEST FAILED!"; else echo "MCAST PACKETS ARE BEING TRANSMITTED!  TEST PASSED!"; fi}
    #)
    #vmsh cmd_set $vm1 "${cmd[*]}"

    #return $result
}    

cleanup_env
setup_env
add_mcast_route_test
mcast_snoop_disabled_test
mcast_snoop_enabled_test

# main

#rlJournalStart
#if [ -z "$JOBID" ]; then
#        echo "Variable jobid not set! Assume developer mode."
#fi

#rlPhaseStartSetup "Set up the environment"
#    rlRun "cleanup_env"
#    rlRun "setup_env"
#rlPhaseEnd

#rlPhaseStartSetup "Add a multicast route to all VMs"
#    rlRun "add_mcast_route_test"
#rlPhaseEnd

#rlPhaseStartSetup "Verify correct behavior when OVS multicast snooping is DISABLED"
#    rlRun "mcast_snoop_disabled_test"
#rlPhaseEnd

#rlPhaseStartSetup "Verify correct behavior when OVS multicast snooping is ENABLED"
#    rlRun "mcast_snoop_enabled_test"
#rlPhaseEnd

#rlPhaseStartSetup "Clean up the environment"
#    rlRun "cleanup_env"
#rlPhaseEnd

#rhts_submit_log -l $result_file

#rlJournalPrintText
#rlJournalEnd

