#!/bin/bash
# vim: dict=/usr/share/beakerlib/dictionary.vim cpt=.,w,b,u,t,i,k sts=4 sw=4 et
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   runtest.sh of /kernel/networking/openvswitch/mcast_snoop
#   Author: Rick Alongi <ralongi@redhat.com>
#
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   Copyright (c) 2017 Red Hat, Inc.
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
dbg_flag=${dbg_flag:-"set +x"}
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
. /mnt/git_repo/kernel/networking/openvswitch/lib_config.sh || exit 1
. /mnt/git_repo/kernel/networking/openvswitch/perf_check/lib_netperf_all.sh || exit 1

# set default password to be used for tests 
password="100yard-"
vm_password="redhat"

# rhel version
rhel_version=$(cut -f1 -d. /etc/redhat-release | sed 's/[^0-9]//g')

# pointer to log file
result_file=${result_file:-"ovs_mcast-snoop_test_result.log"}
selinux_enable=${selinux_enable:-"yes"}

# check for installation of NetworkManager and install if necessary, enable and start service which was likley stopped by the common functions above
pvt_networkmanager_install

vm1=${vm1:-"g1"}
vm2=${vm2:-"g2"}
vm3=${vm3:-"g3"}
vm_list1=$(echo $vm1 $vm2 $vm3)
vm_list2=$(echo $vm2 $vm3)
file_server="netqe-infra01.knqe.lab.eng.bos.redhat.com"

if [ -z "$JOBID" ]; then
	ipaddr=120
else
	ipaddr=$((JOBID % 100 + 20))
fi

ip4addr=192.168.$((ipaddr + 0)).2
ip6addr=2014:$((ipaddr + 0))::2
ip4addr_vm_base=192.168.$((ipaddr + 50))
ip6addr_vm_base=2015:$((ipaddr + 50))
intport_ip4=192.168.$((ipaddr + 50)).41
intport_ip6=2016:$((ipaddr + 50))::41
con_name="static-$iface"
ovsbr="ovsbr1"
intport="intport1"
mtu=${mtu:-"1500"}

iperf_rpm=${iperf_rpm:-"iperf-2.0.4-1.el7.rf.x86_64.rpm"}
iperf_location=${iperf_location:-"http://netqe-infra01.knqe.lab.eng.bos.redhat.com"}
vm_tmp_result_file="/tmp/vm_tmp_result.tmp"

#############################################################################

# function to install necessary packages
do_install()
{
    # epel repo
    pvt_epel_install

    # dos2unix
    pvt_dos2unix_install

    # ovs
    pvt_ovs_install

    #virtualization
    pvt_virt_install

    # brctl
    pvt_brctl_install

    # httpd
    pvt_httpd_install

    # sshpass
    pvt_sshpass_install
}

# function to stop and start processes
iperf_server_vm_start()
{
        local target=$1
        sshpass -p $vm_password ssh root@$target iperf -s -u -B 224.0.55.55 -i 1 -p $iface_vm &
}

iperf_client_vm_start()
{
        local target=$1
        #sshpass -p $vm_password ssh root@$target iperf -c 224.0.55.55 -u -T 32 -t 3 -i 1 -p $iface_vm &
        #sshpass -p $vm_password ssh root@$target iperf -c 224.0.55.55 -u -b -f -t 5 $iface_vm &
        sshpass -p $vm_password ssh root@$target iperf -c 224.0.55.55 -u -b 900m -t 100000
}

iperf_vm_stop()
{
        local target=$1
        sshpass -p $vm_password ssh root@$target pkill iperf || true
}

tcpdump_vm_stop()
{
    local target=$1
    sshpass -p $vm_password ssh root@$target pkill tcpdump || true
}

enable_mcast_snoop()
{
    ovs-vsctl set Bridge $ovsbr mcast_snooping_enable=true
    sleep 3
    get_mcast_snoop_setting
    if [[ $mcast_snoop_setting != "true" ]]; then
        rlLog "Attempt to enable mcast snooping FAILED."
    else
        rlLog "Attempt to enable mcast snooping was successful."
    fi
}

disable_mcast_snoop()
{
    ovs-vsctl set Bridge $ovsbr mcast_snooping_enable=false
    sleep 3
    get_mcast_snoop_setting
    if [[ $mcast_snoop_setting != "false" ]]; then
        rlLog "Attempt to disable mcast snooping FAILED."
    else
        rlLog "Attempt to disable mcast snooping was successful."
    fi
}

get_mcast_snoop_setting()
{
    mcast_snoop_setting=$(ovs-vsctl list bridge ovsbr1 | grep mcast_snooping_enable | awk '{print $2}')
}

# set up environment for tests

setup_env()

{
    local result=0
    # install necessary packages
    do_install
    
    if [[ $selinux_enable == "yes" ]]; then
        enable-selinux
    else
        disable-selinux
    fi

    # VM related setup

    # create OVS bridge to support subsequent VM creation
    create-ovsbr-vsctl $ovsbr
    # add internal port to $ovsbr
    create-ovsbr-port-vsctl -internal $ovsbr $intport
    # assign IP addresses to $intport and set port up
    ip addr add dev $intport $intport_ip4/24
    ip -6 addr add dev $intport $intport_ip6/64
    ip link set dev $intport up
    
    # VM related setup
    for i in $vm_list1; do 
        vm_number=$(echo $i | tr -d g)
        create-vm $i $vm_version $ovsbr
    done

    # update kernel on the VM if specified
    if [[ $up_knl_vm == yes ]]; then
        for i in $vm_list1; do update-kernel-vm $i; done
    fi
    
    # set static IP address on VM    
    for i in $vm_list1; do
        vm_number=$(echo $i | tr -d g)
        #last_octet=$(echo $i | tr -d g)        
        vm_ipaddr="$ip4addr_vm_base.$vm_number"
        echo $vm_ipaddr $i >> /etc/hosts
    
        if [[ $rhel_version -ge 7 ]]; then
            set-vm-ip-nmcli $i $ip4addr_vm_base.$vm_number $ip6addr_vm_base::$vm_number
        else
            set-vm-ip-ifcfg $i $ip4addr_vm_base.$vm_number $ip6addr_vm_base::$vm_number
        fi
    done

    # generate ssh key
    do_ssh_keygen

    # copy ssh key to all VMs
    for i in $vm_list1; do do_ssh_copy_id $i $vm_password; done

    return $result
}

#----------------------------------------------------------

# define the tests

# verify that the mcast route can be added successfully to all VMs
add_mcast_route_test()
{
    for i in $vm_list1; do
        status=$(virsh list --all | grep -i "$i" | awk '{ print $3 }')
        if [[ $status == "shut off" ]]; then
	        virsh start $i && sleep 45
        fi
        rlLog "Adding route to VM $i..."
        rlRun -l "vmsh run_cmd $i /sbin/route -n add -net 224.0.0.0 netmask 240.0.0.0 dev $iface_vm"
        rlLog "Verifying route on VM $i..."
        rlRun -l "vmsh run_cmd $i sleep 2; /sbin/route -n | grep 224"  2>&1 | tee $vm_tmp_result_file
        rlRun -l "check_result_vm $vm_tmp_result_file"  
    done
}

# verify correct behavior when ovs mcast snooping is disabled
mcast_snoop_disabled_test()
{
    disable_mcast_snoop
    
    # start all VMs
    for i in $vm_list1; do
        status=$(virsh list --all | grep -i "$i" | awk '{ print $3 }')
        if [[ $status == "shut off" ]]; then
	        virsh start $i && sleep 45
        fi
    done

    # stop all currently running iperf processes on all VMs
    for i in $vm_list1; do iperf_vm_stop $i; done
    
    # delete any existing trace files on $VM2 and $VM3
    for i in $vm_list2; do
        sshpass -p $vm_password ssh root@$i rm -f /tmp/tcpdump_output1_$i.asc
    done
    
    # stop all currently running tcpdump processes on VM2 and VM3
    for i in $vm_list2; do tcpdump_vm_stop $i; done      
    
    # monitor for mcast packets on $vm2 and $vm3 using tcpdump
    sshpass -p $vm_password ssh root@$vm2 tcpdump -nn -i $iface_vm ip multicast  >> /tmp/tcpdump_output1_$vm2.asc
    sshpass -p $vm_password ssh root@$vm3 tcpdump -nn -i $iface_vm ip multicast  >> /tmp/tcpdump_output1_$vm3.asc

    # launch iperf mcast client on $vm1 to generate mcast traffic
    iperf_client_vm_start $vm1

    # verify that mcast packets are being seen by $vm2 and $vm3 since mcast snooping is disabled
    for i in $vm_list2; do
        rlLog "Checking VM $i trace files..."
        if [[ $(grep 224.0.55.55 /tmp/tcpdump_output1_$i.asc | grep UDP | grep 1470) ]]; then
            rlPass "VM $i saw the expected multicast packets.  Mcast Disabled Test 1: PASSED"
        else
            rlFail "VM $i DID NOT see the expected multicast packets.  Mcast Disabled Test 1: FAILED"
        fi
    done
}

# verify correct behavior when mcast snooping is enabled
mcast_snoop_enabled_test1()
{
	enable_mcast_snoop

    # start all VMs
    for i in $vm_list1; do
        status=$(virsh list --all | grep -i "$i" | awk '{ print $3 }')
        if [[ $status == "shut off" ]]; then
	        virsh start $i && sleep 45
        fi
    done

    # stop all currently running iperf processes on all VMs
    for i in $vm_list1; do iperf_vm_stop $i; done
    
    # stop all currently running tcpdump processes on all VMs
    for i in $vm_list1; do tcpdump_vm_stop $i; done
    
    # delete any existing trace files on $VM2 and $VM3
    for i in $vm_list2; do
        sshpass -p $vm_password ssh root@$i rm -f /tmp/tcpdump_output2_$i.asc
    done

    # monitor for mcast packets on $vm2 and $vm3 using tcpdump 
    sshpass -p $vm_password ssh root@$vm2 tcpdump -nn -i $iface_vm ip multicast  >> /tmp/tcpdump_output2_$vm2.asc
    sshpass -p $vm_password ssh root@$vm3 tcpdump -nn -i $iface_vm ip multicast  >> /tmp/tcpdump_output2_$vm3.asc

    # launch iperf mcast client on $vm1 to generate mcast traffic
    iperf_client_vm_start $vm1

    # verify that mcast packets are seen by $vm2 and $vm3
    for i in $vm_list2; do
        rlLog "Checking VM $i trace files..."
        if [[ $(grep 224.0.55.55 /tmp/tcpdump_output1_$i.asc | grep UDP | grep 1470) ]]; then
            rlPass "VM $i saw the expected multicast packets.  Mcast Enabled Test 1: PASSED"
        else
            rlFail "VM $i DID NOT see the expected multicast packets.  Mcast Enabled Test 1: FAILED"
        fi
    done
}    

mcast_snoop_enabled_test2()
{
    enable_mcast_snoop

    # start all VMs
    for i in $vm_list1; do
        status=$(virsh list --all | grep -i "$i" | awk '{ print $3 }')
        if [[ $status == "shut off" ]]; then
	        virsh start $i && sleep 45
        fi
    done

    # stop all currently running iperf processes on all VMs
    for i in $vm_list1; do iperf_vm_stop $i; done
    
    # stop all currently running tcpdump processes on all VMs
    for i in $vm_list1; do tcpdump_vm_stop $i; done
    
    # delete any existing trace files on $VM2 and $VM3
    for i in $vm_list2; do
        sshpass -p $vm_password ssh root@$i rm -f /tmp/tcpdump_output3_$i.asc
    done
    
    # start iperf server on $vm2 only
    iperf_server_vm_start $vm2
    
    # monitor for mcast packets on $vm2 and $vm3 using tcpdump
sshpass -p $vm_password ssh root@$vm2 tcpdump -nn -i $iface_vm ip multicast  >> /tmp/tcpdump_output3_$vm2.asc
    sshpass -p $vm_password ssh root@$vm3 tcpdump -nn -i $iface_vm ip multicast  >> /tmp/tcpdump_output3_$vm3.asc
    
    # launch iperf mcast client on $vm1 to generate mcast traffic
    iperf_client_vm_start $vm1
    sleep 5

    # verify that mcast packets were seen by $vm2
    rlLog "Checking VM $vm2 trace file..."
    if [[ $(grep 224.0.55.55 /tmp/tcpdump_output1_$vm2.asc | grep UDP | grep 1470) ]]; then
        rlPass "VM $vm2 saw the expected multicast packets.  Mcast Enabled Test 2: PASSED"
    else
        rlFail "VM $vm2 DID NOT see the expected multicast packets.  Mcast Enabled Test 2: FAILED"
    fi
    
    # verify that mcast packets were NOT seen by $vm3
    if [[ ! $(grep 224.0.55.55 /tmp/tcpdump_output1_$vm3.asc | grep UDP | grep 1470) ]]; then
        rlPass "VM $vm3 DID NOT see multicast packets which is the expected result.  Mcast Enabled Test 2: PASSED"
    else
        rlFail "VM $vm3 saw multicast packets which is NOT the expected result.  Mcast Enabled Test 2: FAILED"
    fi    
}

mcast_snoop_enabled_test3()
{
    enable_mcast_snoop

    # start all VMs
    for i in $vm_list1; do
        status=$(virsh list --all | grep -i "$i" | awk '{ print $3 }')
        if [[ $status == "shut off" ]]; then
	        virsh start $i && sleep 45
        fi
    done

    # stop all currently running iperf processes on all VMs
    for i in $vm_list1; do iperf_vm_stop $i; done
    
    # stop all currently running tcpdump processes on all VMs
    for i in $vm_list1; do tcpdump_vm_stop $i; done
    
    # delete any existing trace files on $VM2 and $VM3
    for i in $vm_list2; do
        sshpass -p $vm_password ssh root@$i rm -f /tmp/tcpdump_output3_$i.asc
    done
    
    # start iperf server on $vm2 and $vm3
    iperf_server_vm_start $vm2
    iperf_server_vm_start $vm3
    
    # monitor for mcast packets on $vm2 and $vm3 using tcpdump
    sshpass -p $vm_password ssh root@$vm2 tcpdump -nn -i $iface_vm ip multicast  >> /tmp/tcpdump_output4_$vm2.asc
    sshpass -p $vm_password ssh root@$vm3 tcpdump -nn -i $iface_vm ip multicast  >> /tmp/tcpdump_output4_$vm3.asc
    
    # launch iperf mcast client on $vm1 to generate mcast traffic
    iperf_client_vm_start $vm1
    sleep 5

    # verify that mcast packets are seen by $vm2 and $vm3
    for i in $vm_list2; do
        rlLog "Checking VM $i trace files..."
        if [[ $(grep 224.0.55.55 /tmp/tcpdump_output4_$i.asc | grep UDP | grep 1470) ]]; then
            rlPass "VM $i saw the expected multicast packets.  Mcast Enabled Test 3: PASSED"
        else
            rlFail "VM $i DID NOT see the expected multicast packets.  Mcast Enabled Test 3: FAILED"
        fi
    done  
}

# main

# get kernel and OVS version info and write to $result_file
echo "Kernel version: $(uname -r)" >> $result_file
get-ovs-ver >> $result_file
echo "**************************************" >> $result_file

rlJournalStart
if [ -z "$JOBID" ]; then
        echo "Variable jobid not set! Assume developer mode."
fi

rlPhaseStartSetup "Set up the environment"
    rlRun "cleanup_env"
    rlRun "setup_env"
rlPhaseEnd

ovs_ver=$(ovs-vsctl show | grep "ovs_version" | awk '{print $2}' | tr -d '["]')
ovs_ver_num=$(echo $ovs_ver | awk -F "." '{print $1$2$3}')

if [[ $ovs_ver_num -lt 240 ]]; then
    rlLogWarning "OVS version is not 2.4.0 or higher.  Multicast snooping is not supported.  Exiting test..."
    rhts-abort -t recipe
fi

rlPhaseStartSetup "Add a multicast route to all VMs"
    rlRun -l "add_mcast_route_test"
rlPhaseEnd

rlPhaseStartSetup "Test 1 to verify correct behavior when OVS multicast snooping is DISABLED"
    rlRun -l "mcast_snoop_disabled_test"
rlPhaseEnd

rlPhaseStartSetup "Test 1 to verify correct behavior when OVS multicast snooping is ENABLED"
    rlRun -l "mcast_snoop_enabled_test1"
rlPhaseEnd

rlPhaseStartSetup "Test 2 to verify correct behavior when OVS multicast snooping is ENABLED"
    rlRun -l "mcast_snoop_enabled_test2"
rlPhaseEnd

rlPhaseStartSetup "Test 3 to verify correct behavior when OVS multicast snooping is ENABLED"
    rlRun -l "mcast_snoop_enabled_test3"
rlPhaseEnd

rhts_submit_log -l $result_file

rlJournalPrintText
rlJournalEnd

