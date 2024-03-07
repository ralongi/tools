# To manually set up for upgrade_ovs test

git_install()
{
	if [ $# -gt 0 ]; then 
		git_dir=$1
	else
		git_dir="/mnt/git_repo"
	fi
	
	echo "Installing Git if not already installed and cloning repo..."
    yum -y install git || true
    mkdir "$git_dir"
	pushd "$git_dir" && git clone git://pkgs.devel.redhat.com/tests/kernel && popd
}

git_install /mnt/tests
git_install /mnt/git_repo

PACKAGE="kernel"
. /mnt/tests/kernel/networking/common/include.sh || exit 1

source_function_files()
{
    yum -y install wget
    function_file_location="pkgs.devel.redhat.com/cgit/tests/kernel/plain/networking/openvswitch/tools/"
	pushd /home
	if [[ ! -d $function_file_location ]]; then
	    wget --execute="robots = off" --mirror --convert-links --no-parent --wait=1 "http://"$function_file_location
	fi
	pushd $function_file_location
	local file_list=$(ls *.sh)
	for file in $file_list; do
	    source $file
	    if [[ $? -eq 0 ]]; then
	        echo "Sourcing of $file was SUCCESSFUL."
	    else
	        echo "Sourcing of $file was UNSUCCESSFUL."
	    fi
	done	
	popd
}

source_function_files

# Download tools needed for test
download_tools()
{
    local tool_location="http://pkgs.devel.redhat.com/cgit/tests/kernel/plain/networking/openvswitch/tools"
    local tool_list="ovs-lib ovs-save XenaPktSend.py"
    for tool in $tool_list; do
        if [[ ! -s /home/"$tool" ]]; then
            wget -O /home/$tool $tool_location/$tool
            if [[ -s /home/$tool ]]; then
                echo "Download of $tool was SUCCESSFUL"
                chmod 777 /home/$tool
            else
                echo "Download of $tool was UNSUCCESSFUL"
            fi
        fi
    done
}

download_tools

rhel_version=$(cut -f1 -d. /etc/redhat-release | sed 's/[^0-9]//g')
file_server="netqe-infra01.knqe.lab.eng.bos.redhat.com"
ovsbr="ovsbr0"
selinux_enable=${selinux_enable:-"yes"}
overall_port_start=${overall_port_start:-"1"}
overall_port_end=${overall_port_end:-"1000"}
flow_start=${flow_start:-"1"}
flow_end=${flow_end:-"1000"}
flows_file="/home/$ovsbr"_flows.txt
baseline_repo_url=$(grep baseurl /etc/yum.repos.d/beaker-Server.repo | awk -F "=" '{print $2}')
dpdk_iface1=${dpdk_iface1:-"p1p1"}
dpdk_iface2=${dpdk_iface2:-"p1p2"}
vm_list=${vm_list:-"1"}
vm_version=${vm_version:-""}
if [[ -z $vm_version ]]; then
    vm_version=$(cat /etc/redhat-release | awk '{print $7}' | tr -d " ")
fi
vm_vhost_mode=${vm_vhost_mode:-"server"}
traffic_topo=${traffic_topo:-"pvp"}
use_dpdk=${use_dpdk:-"no"}
dpdk_version=${dpdk_version=:-"1711"}
create_many_flows=${create_many_flows:-"yes"}
auto_flow_restore=${auto_flow_restore:-"no"}
repo_target_compose_id=${repo_target_compose_id:-""}
install_ofed=${install_ofed:-"no"}
ovs_selinux_rpm=${ovs_selinux_rpm:-"http://download.devel.redhat.com/brewroot/packages/openvswitch-selinux-extra-policy/1.0/3.el7fdp/noarch/openvswitch-selinux-extra-policy-1.0-3.el7fdp.noarch.rpm"}
install_latest_ovs_rpm=${install_latest_ovs_rpm:-"no"}

# Variables below are for layered product (lp) such as RHELOSP, RHOCP, RHEV
lp_test_type=${lp_test_type:-""}
lp_starting_version=${lp_starting_version:-""}
lp_target_version=${lp_target_version:-""}

if [[ ! -s /home/dpdk_pci_slot1.txt ]]; then
	ethtool -i "$dpdk_iface1" | grep "bus-info" | awk '{print $2}' > /home/dpdk_pci_slot1.txt
fi

if [[ ! -s /home/dpdk_pci_slot2.txt ]]; then
	ethtool -i "$dpdk_iface2" | grep "bus-info" | awk '{print $2}' > /home/dpdk_pci_slot2.txt
fi

dpdk_pci_slot1=$(cat /home/dpdk_pci_slot1.txt)
dpdk_pci_slot2=$(cat /home/dpdk_pci_slot2.txt)

result_file="ovs_upgrade_test_$base_ver"_to_"$upgrade_ver.log"
return_codes_file="/home/return_codes.log"
skip_test1=${skip_test1:-"no"}
skip_test2=${skip_test2:-"no"}

### export variables for this terminal session

export dbg_flag="set -x"
export install_latest_ovs_rpm="no"
export ovs_rpm_version="2.9.0"
export ovs_selinux_rpm="http://download.devel.redhat.com/brewroot/packages/openvswitch-selinux-extra-policy/1.0/6.el8fdp/noarch/openvswitch-selinux-extra-policy-1.0-6.el8fdp.noarch.rpm"
export lp_test_type="RHELOSP"
export lp_starting_version="10"
export lp_target_version="13"
export dpdk_version="1711-15"
export selinux_enable="yes"
export install_ofed="yes"
export repo_target_compose_id="RHEL-7.5"
export vm_version="7.5"
export create_many_flows="yes"
export traffic_topo="pvp"
export xena_test_duration="600"
export NAY="yes"
export NIC_NUM="all"
export NM_CTL="yes"

rm -f /home/junk.txt
wget -O /home/junk.txt http://netqe-infra01.knqe.lab.eng.bos.redhat.com/packages/junk.txt
password=$(cat /home/junk.txt)

pvt_epel_install
if [[ ! $(which sshpass) ]]; then yum -y install sshpass; fi
sleep 2
if [[ ! $(which sosreport) ]]; then yum -y install sos; fi

# install tuned
pvt_tuned_install

# get latest openvswitch package info
if [[ $install_latest_ovs_rpm == "yes" ]]; then check_latest_openvswitch_package; fi

if [[ $install_latest_ovs_rpm != "yes" ]]; then 
    ovs_end_ver=$lp_test_type"_"$lp_target_version
else
    ovs_end_ver=$latest_ovs_ver
fi

perf_result_file="$lp_test_type"_$lp_starting_version"_to_"$ovs_end_ver"_perf_results.log"

if [[ $install_ofed == "yes" ]]; then rlRun "ofed_install"; fi
configure_hugepages
tune_host
echo "Sleeping 15 seconds and then rebooting..."
sleep 15
reboot

############################## after reboot:
rhel_version=$(cut -f1 -d. /etc/redhat-release | sed 's/[^0-9]//g')
file_server="netqe-infra01.knqe.lab.eng.bos.redhat.com"
ovsbr="ovsbr0"
selinux_enable=${selinux_enable:-"yes"}
overall_port_start=${overall_port_start:-"1"}
overall_port_end=${overall_port_end:-"1000"}
flow_start=${flow_start:-"1"}
flow_end=${flow_end:-"1000"}
flows_file="/home/$ovsbr"_flows.txt
baseline_repo_url=$(grep baseurl /etc/yum.repos.d/beaker-Server.repo | awk -F "=" '{print $2}')
dpdk_iface1=${dpdk_iface1:-"p3p1"}
dpdk_iface2=${dpdk_iface2:-"p3p2"}
vm_list=${vm_list:-"1"}
vm_version=${vm_version:-""}
if [[ -z $vm_version ]]; then
    vm_version=$(cat /etc/redhat-release | awk '{print $7}' | tr -d " ")
fi
vm_vhost_mode=${vm_vhost_mode:-"server"}
traffic_topo=${traffic_topo:-"pvp"}
use_dpdk=${use_dpdk:-"no"}
dpdk_version=${dpdk_version=:-"1711-15"}
create_many_flows=${create_many_flows:-"yes"}
auto_flow_restore=${auto_flow_restore:-"no"}
repo_target_compose_id=${repo_target_compose_id:-""}
install_ofed=${install_ofed:-"no"}
ovs_selinux_rpm=${ovs_selinux_rpm:-"http://download.devel.redhat.com/brewroot/packages/openvswitch-selinux-extra-policy/1.0/3.el7fdp/noarch/openvswitch-selinux-extra-policy-1.0-3.el7fdp.noarch.rpm"}
install_latest_ovs_rpm=${install_latest_ovs_rpm:-"no"}

# Variables below are for layered product (lp) such as RHELOSP, RHOCP, RHEV
lp_test_type=${lp_test_type:-""}
lp_starting_version=${lp_starting_version:-""}
lp_target_version=${lp_target_version:-""}

if [[ ! -s /home/dpdk_pci_slot1.txt ]]; then
	ethtool -i "$dpdk_iface1" | grep "bus-info" | awk '{print $2}' > /home/dpdk_pci_slot1.txt
fi

if [[ ! -s /home/dpdk_pci_slot2.txt ]]; then
	ethtool -i "$dpdk_iface2" | grep "bus-info" | awk '{print $2}' > /home/dpdk_pci_slot2.txt
fi

dpdk_pci_slot1=$(cat /home/dpdk_pci_slot1.txt)
dpdk_pci_slot2=$(cat /home/dpdk_pci_slot2.txt)

result_file="ovs_upgrade_test_$base_ver"_to_"$upgrade_ver.log"
return_codes_file="/home/return_codes.log"
skip_test1=${skip_test1:-"no"}
skip_test2=${skip_test2:-"no"}

### export variables for this terminal session

export dbg_flag="set -x"
export install_latest_ovs_rpm="no"
export ovs_rpm_version="2.9.0"
#export ovs_selinux_rpm="http://download.devel.redhat.com/brewroot/packages/openvswitch-selinux-extra-policy/1.0/6.el8fdp/noarch/openvswitch-selinux-extra-policy-1.0-6.el8fdp.noarch.rpm"
export lp_test_type="RHELOSP"
export lp_starting_version="12"
export lp_target_version="14"
export dpdk_version="1711-15"
export selinux_enable="yes"
export install_ofed="yes"
export repo_target_compose_id="RHEL-7.6"
export vm_version="7.5"
export create_many_flows="yes"
export traffic_topo="pvp"
export xena_test_duration="600"
export NAY="yes"
export NIC_NUM="all"
export NM_CTL="yes"


source_function_files()
{
    yum -y install wget
    function_file_location="pkgs.devel.redhat.com/cgit/tests/kernel/plain/networking/openvswitch/tools/"
	pushd /home
	if [[ ! -d $function_file_location ]]; then
	    wget --execute="robots = off" --mirror --convert-links --no-parent --wait=1 "http://"$function_file_location
	fi
	pushd $function_file_location
	local file_list=$(ls *.sh)
	for file in $file_list; do
	    source $file
	    if [[ $? -eq 0 ]]; then
	        echo "Sourcing of $file was SUCCESSFUL."
	    else
	        echo "Sourcing of $file was UNSUCCESSFUL."
	    fi
	done	
	popd
}

source_function_files

cleanup_env

if [[ $selinux_enable == "yes" ]]; then
        enable-selinux
    else
        disable-selinux
fi

rm -Rf /baseline_repos
mkdir /baseline_repos && cp /etc/yum.repos.d/*.repo /baseline_repos
touch /home/baseline_kernel.txt && uname -r > /home/baseline_kernel.txt
pvt_python34_install
nsconnect_install
source_function_files
netscout_cable Netqe9_p3p1 XenaM5P0
netscout_cable Netqe9_p3p2 XenaM5P1
pvt_driverctl_install
cleanup_ovs
yum localinstall -y http://download.lab.bos.redhat.com/rcm-guest/puddles/OpenStack/rhos-release/rhos-release-latest.noarch.rpm
generate_lp_repo starting
yum clean expire-cache
yum -y install http://download.devel.redhat.com/brewroot/packages/openvswitch-selinux-extra-policy/1.0/3.el7fdp/noarch/openvswitch-selinux-extra-policy-1.0-3.el7fdp.noarch.rpm
yum -y install openvswitch
systemctl enable openvswitch.service
ovs_start
ovs-vsctl --if-exists del-br $ovsbr
ovs-vsctl add-br $ovsbr

if [[ $traffic_topo == "pvp" ]]; then 
    yum -y install libvirt
    systemctl enable libvirtd && systemctl start libvirtd
    yum install -y qemu-kvm-rhev*
    for i in $vm_list; do create-vm $i $vm_version $ovsbr; done
fi
if [[ $use_dpdk != "yes" ]]; then
    xena_traffic_topo_config
fi

## Test 1

if [[ $selinux_enable == "yes" ]]; then
    enable-selinux
else
    disable-selinux
fi
            
get_ovs_status        
systemctl enable openvswitch.service
ovs_start
ovs-vsctl --if-exists del-br $ovsbr
ovs-vsctl add-br $ovsbr

if [[ $traffic_topo == "pvp" ]]; then
    for i in $(virsh list --all | grep -v Name | awk '{print $2}'); do
        reset_vm $i
    done
fi

for vm in $(virsh list --all | grep -v Name | awk '{print $2}'); do
    if [[ $(virsh list --all | grep $vm | awk '{print $3}') != "running" ]] && [[ $use_dpdk == "yes" ]]; then
        echo "VM $vm state: $(virsh list --all | grep $vm | awk '{print $3}')"
        fix_vhost_issues
    fi
done

for vm in $(virsh list --all | grep -v Name | awk '{print $2}'); do
    if [[ $(virsh list --all | grep $vm | awk '{print $3}') != "running" ]]; then
        echo "Can't get VM $vm into running state.  Exiting test..."
    fi
done
if [[ $use_dpdk != "yes" ]]; then
    xena_traffic_topo_config
fi

add_ports $ovsbr
add_flows $ovsbr
save_flows $ovsbr
create_search_keys_flows $ovsbr
create_search_keys_ports $ovsbr
check_ports_sanity $ovsbr
check_flows_sanity $ovsbr
get_ovs_running_version
set_expect_ovs_service_restart
get_ovs_service_pids
set_pid1
generate_lp_repo target
yum clean expire-cache
check_need_to_upgrade

for i in $vm_list; do run_testpmd $i; done

xena_traffic_sanity_check
echo "$xena_disruption_time"

yum -y update openvswitch
yum -y update libvirt
yum -y update qemu-kvm-rhev*
get_ovs_service_pids
set_pid2
check_ovs_service_restart
test_ovs_service_restart

if [[ $auto_flow_restore == "no" ]] && [[ $ovs_restarted == "yes" ]]; then
    rlLog "Restoring flows manually..."
    rlRun "ovs-ofctl del-flows $ovsbr && restore_flows $ovsbr"
fi

xena_traffic_disruption_test
echo "$xena_disruption_time"

##########################################
yum -y remove openvswitch-selinux-extra-policy
cleanup_ovs
yum -y remove libvirt
for pkg in $(rpm -qa | grep qemu); do
    yum -y remove $pkg
done

rhos-release -x $lp_starting_version
yum -y install openvswitch
if [[ $traffic_topo == "pvp" ]]; then 
    yum -y install libvirt
    systemctl enable libvirtd && systemctl start libvirtd
    yum install -y qemu-kvm-rhev*                
fi

systemctl enable openvswitch.service
systemctl start openvswitch

ovs-vsctl --if-exists del-br $ovsbr
ovs-vsctl add-br $ovsbr
if [[ $traffic_topo == "pvp" ]]; then for i in $(virsh list --all | grep -v Name | awk '{print $2}'); do virsh destroy $i; sleep 2; virsh start $i; done; fi
virsh list --all
xena_traffic_topo_config
export create_many_flows="no"
add_flows $ovsbr
save_flows $ovsbr
create_search_keys_flows $ovsbr
ovs-vsctl show
ovs-ofctl dump-flows $ovsbr
for i in $(virsh list --all | grep -v Name | awk '{print $2}'); do run_testpmd $i; done
xena_traffic_sanity_check

scl enable rh-python34 'python /home/XenaPktSend.py -c 10.19.15.19 -m 5 -d 600 -s 64 -f 350000'

yum -y update qemu-kvm-rhev*
rhos-release -x 13
yum -y update openvswitch
yum -y update libvirt
























python /home/XenaPktSend.py -c 10.19.15.19 -m 5 -d 60 -s 64 -f 350000
sleep 10
systemctl restart openvswitch

##
del_flows $ovsbr
export flow_start="1"
export flow_end="1000"
#export create_many_flows="no"
export create_many_flows="yes"
add_flows $ovsbr
save_flows $ovsbr
create_search_keys_flows $ovsbr
ovs-ofctl dump-flows $ovsbr | wc -l

scl enable rh-python34 'python /home/XenaPktSend.py -c 10.19.15.19 -m 5 -d 15 -s 64 -f 350000'

scl enable rh-python34 'python /home/XenaPktSend.py -c 10.19.15.19 -m 5 -d 60 -s 64 -f 350000'       

re()
{
	SECONDS=0
	systemctl restart openvswitch.service && ovs-ofctl del-flows $ovsbr && ovs-appctl dpctl/del-flows system@ovs-system && restore_flows $ovsbr
	#systemctl restart openvswitch.service && ovs-ofctl del-flows $ovsbr && restore_flows $ovsbr && ovs-appctl dpctl/del-flows system@ovs-system
	time_to_execute=$SECONDS
	echo "Time to restart and restore flows: $time_to_execute seconds"
	echo "Number of flows restored: $(ovs-ofctl dump-flows $ovsbr | wc -l)"
}

restart_ovs











