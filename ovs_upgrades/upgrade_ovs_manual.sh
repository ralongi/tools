#!/bin/bash

# script to manually test basic ovs upgrade

dbg_flag=${dbg_flag:-"set +x"}
$dbg_flag
rhel_version=$(cut -f1 -d. /etc/redhat-release | sed 's/[^0-9]//g')
if [[ $rhel_version -eq 7 ]]; then
	pkg_cmd="yum"
else
	pkg_cmd="dnf"
fi

. /tmp/package_list.sh

FDP_RELEASE=${FDP_RELEASE:-""}
RPM_OVS=${RPM_OVS:-""}
STARTING_RPM_OVS_SELINUX_EXTRA_POLICY=${STARTING_RPM_OVS_SELINUX_EXTRA_POLICY:-""}
STARTING_RPM_OVS=${STARTING_RPM_OVS:-""}
OVS_LATEST_STREAM_PKG=${OVS_LATEST_STREAM_PKG:-""}
STARTING_RPM_OVS_SELINUX_EXTRA_POLICY_RPM=$(echo $STARTING_RPM_OVS_SELINUX_EXTRA_POLICY | awk -F "/" '{print $NF}')
STARTING_RPM_OVS_RPM=$(echo $STARTING_RPM_OVS | awk -F "/" '{print $NF}')
RPM_OVS_RPM=$(echo $RPM_OVS | awk -F "/" '{print $NF}')

#if [[ $rhel_version == 7 ]]; then
#	OVS_LATEST_STREAM_PKG=$OVS212_20C_RHEL7
#elif [[ $rhel_version == 8 ]]; then
#	OVS_LATEST_STREAM_PKG=$OVS213_20C_RHEL8
#fi

STARTING_RPM_OVS_SELINUX_EXTRA_POLICY=${STARTING_RPM_OVS_SELINUX_EXTRA_POLICY:-""}
STARTING_RPM_OVS=${STARTING_RPM_OVS:-""}
STARTING_RPM_OVS_SELINUX_EXTRA_POLICY_RPM=$(echo $STARTING_RPM_OVS_SELINUX_EXTRA_POLICY | awk -F "/" '{print $NF}')
STARTING_RPM_OVS_RPM=$(echo $STARTING_RPM_OVS | awk -F "/" '{print $NF}')
OVS_LATEST_STREAM_PKG_RPM=$(echo $OVS_LATEST_STREAM_PKG | awk -F "/" '{print $NF}')

RPM_OVS_RPM=$(echo $RPM_OVS | awk -F "/" '{print $NF}')
RESULTS_FILE=/tmp/$FDP_RELEASE"_"$STARTING_RPM_OVS_RPM"_"$RPM_OVS_RPM"_results.txt"

rm -f $RESULTS_FILE  && touch $RESULTS_FILE

if [[ $STARTING_RPM_OVS_RPM == $RPM_OVS_RPM ]] || [[ $STARTING_RPM_OVS_RPM == $OVS_LATEST_STREAM_PKG_RPM ]]; then
	echo "Skipping this test as starting and ending OVS packages are the same" | tee -a $RESULTS_FILE
	exit 0
fi

rpm -q yum-utils
if [[ $? != 0 ]]; then $pkg_cmd -y install $pkg_cmd-utils; fi
yum-complete-transaction –cleanup-only

ovsbr="ovsbr0"
flow_start=${flow_start:-"1"}
flow_end=${flow_end:-"1000"}
flows_file="/home/$ovsbr"_flows.txt
create_many_flows=${create_many_flows:-"yes"}

pvt_epel_install()
{
	local rhel_version=$(cut -f1 -d. /etc/redhat-release | sed 's/[^0-9]//g')
	local arch=$(uname -m)

	if rpm -q epel-release 2>/dev/null; then
		echo "EPEL repo is already installed"
		return 0
	else
		echo "Installing EPEL repo..."
		timeout 120s bash -c "until ping -c3 dl.fedoraproject.org; do sleep 10; done"
		$pkg_cmd -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-$rhel_version.noarch.rpm
	fi
}

pvt_sshpass_install()
{
	if rpm -q sshpass 2>/dev/null; then
		echo "sshpass is already installed."
		return 0
	else
		echo "Installing sshpass..."
		$pkg_cmd -y install sshpass
	fi
}

cleanup_ovs()
{
	$dbg_flag
	if [[ $(rpm -qa | grep openvswitch) ]]; then
		for bridge in $(ovs-vsctl list-br); do ovs-vsctl del-br $bridge; done
		systemctl stop openvswitch
		$pkg_cmd -y remove openvswitch*
		rm -Rf /etc/openvswitch
		rm -Rf /var/log/openvswitch
		rm -f /etc/sysconfig/openvswitch
		if [[ $(rpm -q openvswitch-selinux-extra-policy) ]]; then $pkg_cmd -y remove openvswitch-selinux-extra-policy; fi
		if [[ $(cut -d: -f1 /etc/group | grep hugetlbfs) ]]; then groupdel hugetlbfs; fi
		if [[ $(cut -d: -f1 /etc/group | grep openvswitch) ]]; then userdel openvswitch; fi
		#for dir in $(ls -d /dev/hugepages/*); do rm -Rf $dir; done
		#rm -f /dev/hugepages/*
	else
		echo "openvswitch is not installed so no cleanup necessary"
	fi
}

add_flows()
{
	$dbg_flag
	target_bridge=$1
	if [[ $# -lt 1 ]]; then target_bridge=$ovsbr; fi
	
	# delete any existing flows
	ovs-ofctl del-flows $target_bridge
	
	# write 1K flow rules to file
	rm -f $flows_file
	if [[ $create_many_flows == "yes" ]]; then
		for i in $(seq $flow_start $flow_end); do
			echo "in_port=$i,idle_timeout=0,actions=output:$i" >> $flows_file
		done
	fi

	if [[ $traffic_topo == "pvp" ]]; then    
		# add additional flows used for traffic disruption calculation to file (below is for PVP)
		echo "in_port=1005,idle_timeout=0,actions=output:1015" >> $flows_file
		echo "in_port=1015,idle_timeout=0,actions=output:1005" >> $flows_file
		echo "in_port=1010,idle_timeout=0,actions=output:1020" >> $flows_file
		echo "in_port=1020,idle_timeout=0,actions=output:1010" >> $flows_file
	else
		# add additional flows used for traffic disruption calculation to file (below is for P2P)
		echo "in_port=1005,idle_timeout=0,actions=output:1010" >> $flows_file
		echo "in_port=1010,idle_timeout=0,actions=output:1005" >> $flows_file
	fi
	
    # add flows to $ovsbr and display them
    ovs-ofctl add-flows $target_bridge $flows_file
    ovs-ofctl dump-flows $target_bridge
}

confirm_ovs_active_status()
{
	if [[ $(systemctl is-active openvswitch) != "active" ]]; then
		echo "FAIL: openvswitch.service did not start as expected." | tee -a $RESULTS_FILE
			journalctl -xe
			exit 1
	else
		echo "PASS: openvswitch.service started/restarted/reloaded successfully." | tee -a $RESULTS_FILE
	fi
}

reload_openvswitch_test()
{
	$dbg_flag
	echo "Reloading openvswitch.service (flows should not be impacted)..."
	SECONDS=0
	#{ time systemctl reload openvswitch 2>1 ; } 2> time.log
	#restart_time=$(grep real time.log | awk '{print $2}')
	echo ""  | tee -a $RESULTS_FILE
	echo "TEST: Verify that openvswitch.service successfully reloaded" | tee -a $RESULTS_FILE
	systemctl reload openvswitch
	if [[ $(systemctl status openvswitch | grep "ovs-systemd-reload" | grep SUCCESS) ]]; then
		echo "PASS: openvswitch successfully reloaded" | tee -a $RESULTS_FILE
	else
		echo "FAIL: openvswitch did NOT reload as expected" | tee -a $RESULTS_FILE
		return 1
	fi
	echo ""  | tee -a $RESULTS_FILE
	echo "TEST: Verify that openvswitch.service reloaded in 2 seconds or less" | tee -a $RESULTS_FILE
	echo "Time to complete openvswitch.service restart/reload: $SECONDS second(s)"
	if [[ $SECONDS -le 2 ]]; then
		echo "PASS: Restart time was acceptable" | tee -a $RESULTS_FILE
		#echo "FAIL: Restart time was greater than 1 second" | tee -a $RESULTS_FILE
	else
		echo "FAIL: Restart time was NOT acceptable" | tee -a $RESULTS_FILE
		#echo "PASS: Restart time was less than/equal to 1 second" | tee -a $RESULTS_FILE
	fi

	ovs_status=$(systemctl is-active openvswitch.service)
	get_ovs_running_version
	#get_ovs_target_version
	echo ""  | tee -a $RESULTS_FILE
	echo "TEST: Verify that openvswitch.service is running/active" | tee -a $RESULTS_FILE
	if [[ $ovs_status != "active" ]]; then
		echo "FAIL: openvswitch.service did not start as expected" | tee -a $RESULTS_FILE
		exit 1
	else
		echo "PASS: openvswitch.service is running as expected" | tee -a $RESULTS_FILE
		echo ""  | tee -a $RESULTS_FILE
		echo "TEST: Verify that openvswitch running version was upgraded as expected" | tee -a $RESULTS_FILE
		if [[ $ovs_running_version == $ovs_target_version ]]; then
			echo "PASS: It appears that the OVS running version upgrade was SUCCESSFUL" | tee -a $RESULTS_FILE
		else
			echo "FAIL: It appears that the OVS running version upgrade FAILED" | tee -a $RESULTS_FILE
		fi			
	fi
}

get_ovs_running_version()
{
	$dbg_flag
	installed_openvswitch_package=$(rpm -qa | grep openvswitch | egrep -v 'selinux|product')
	ovs_running_version=$(ovs-vsctl show | grep -m 1 ovs_version | awk '{print $2}' | tr -d '"')
	if [[ $ovs_running_version ]]; then
		echo "Running OVS version: $ovs_running_version"
		ovs_running_version_short=$( echo $ovs_running_version | awk -F "." '{print $1"."$2}')	
	elif [[ -z $ovs_running_version ]]; then
		ovs_running_version=$(ovs-vsctl --version | grep -m 1 ovs-vsctl | awk '{print $NF}')
		ovs_running_version_short=$( echo $ovs_running_version | awk -F "." '{print $1"."$2}')
		echo "OVS service does not appear to be running.  Installed openvswitch package is: $installed_openvswitch_package"
	fi
}

get_ovs_target_version()
{
	$dbg_flag
	$pkg_cmd -y install $STARTING_RPM_OVS_SELINUX_EXTRA_POLICY $RPM_OVS
	systemctl start openvswitch
	sleep 3
	#ovs_target_version=$(echo $RPM_OVS | awk -F "/" '{print $7}')
	ovs_target_version=$(ovs-vsctl show | grep -m 1 ovs_version | awk '{print $2}' | tr -d '"')
	systemctl stop openvswitch
	sleep 3
}

get_ovs_stream()
{
        $dbg_flag
        stream=$(echo $OVS_LATEST_STREAM_PKG | awk -F "/" '{print $6}')
        if [[ $(echo $stream) == "openvswitch" ]]; then
                ovs_stream="2.9"
        else
                ovs_stream=$(echo $stream | tr -d "openvswitch")
        fi
        echo "OVS stream is: $ovs_stream"
}

create_local_upgrade_repo()
{
	$dbg_flag
	echo "RHEL VERSION is: $rhel_version"
	echo "The OVS stream is: $ovs_stream"
	today_date=$(date "+%a %b %d %Y")
	openvswitch_rpm_name=$(echo $OVS_LATEST_STREAM_PKG | awk -F "/" '{print $NF}')
	if [[ ! $(echo $openvswitch_rpm_name | awk -F "." '{print $5}' | egrep 'el7fdp|el8fdp') ]]; then
		openvswitch_rpm_name=$(echo  $openvswitch_rpm_name | awk -F "." '{print $1"."$2"."$3"."$4"."$6"."$7"."$8}')
	fi
	rm -f /etc/yum.repos.d/mylocalrepo.repo 
	rm -Rf /tmp/mylocalrepo
	get_ovs_stream
	$pkg_cmd -y install wget
	$pkg_cmd -y install rpm-build
	$pkg_cmd -y install createrepo
	if [[ ! -e ~/rpmbuild/SPECS ]]; then mkdir -p ~/rpmbuild/SPECS; fi
	rm -f ~/rpmbuild/SPECS/product-openvswitch.spec
	wget -q -O ~/rpmbuild/SPECS/product-openvswitch.spec http://netqe-infra01.knqe.lab.eng.bos.redhat.com/misc/product-openvswitch.spec
	sed -i "s/ovs_stream/$ovs_stream/g" ~/rpmbuild/SPECS/product-openvswitch.spec
	sed -i "s/today_date/$today_date/g" ~/rpmbuild/SPECS/product-openvswitch.spec

	rpmbuild -ba ~/rpmbuild/SPECS/product-openvswitch.spec
	if [[ ! -e /tmp/mylocalrepo ]]; then mkdir /tmp/mylocalrepo; fi
	if [[ ! -e /tmp/mylocalrepo/Packages ]]; then mkdir /tmp/mylocalrepo/Packages; fi
	rm -f /tmp/mylocalrepo/Packages/*

	#/bin/cp -f ~/rpmbuild/RPMS/noarch/product-openvswitch-$ovs_stream-1.el"$rhel_version".noarch.rpm /tmp/mylocalrepo/Packages
	/bin/cp -f ~/rpmbuild/RPMS/noarch/product-openvswitch*.rpm /tmp/mylocalrepo/Packages
	wget -q -O /tmp/mylocalrepo/Packages/$openvswitch_rpm_name $OVS_LATEST_STREAM_PKG
	createrepo /tmp/mylocalrepo

	cat <<-EOF > /etc/yum.repos.d/mylocalrepo.repo
		[mylocalrepo]
		name=mylocalrepo
		baseurl=file:///tmp/mylocalrepo
		enabled=1
		gpgcheck=0
	EOF

	yum clean all expire-cache
	rm -rf /var/cache/yum
	sleep 5

	$pkg_cmd info product-openvswitch
	$pkg_cmd info openvswitch$ovs_stream
}

pvt_epel_install
pvt_sshpass_install
wget -O /tmp/junk.txt http://netqe-infra01.knqe.lab.eng.bos.redhat.com/packages/junk.txt
sleep 3
SSHPASS=$(cat /tmp/junk.txt)
yes "y" | ssh-keygen -o -t ed25519 -f ~/.ssh/id_rsa -N ""
wait
sleep 3
sshpass -f /tmp/junk.txt ssh-copy-id -o "StrictHostKeyChecking no" -i ~/.ssh/id_rsa.pub root@netqe-infra01.knqe.lab.eng.bos.redhat.com
wait
sleep 3
ssh -q root@netqe-infra01.knqe.lab.eng.bos.redhat.com exit
if [[ $? -ne 0 ]]; then 
    sshpass -f /tmp/junk.txt ssh-copy-id -o "StrictHostKeyChecking no" -i ~/.ssh/id_rsa.pub root@netqe-infra01.knqe.lab.eng.bos.redhat.com
    wait
    sleep 3
fi
cleanup_ovs
get_ovs_target_version
cleanup_ovs
get_ovs_stream
create_local_upgrade_repo

echo "===========================================================================" | tee -a $RESULTS_FILE
echo "Package Info:" | tee -a $RESULTS_FILE
echo "RHEL VERSION: $rhel_version" | tee -a $RESULTS_FILE
echo "Kernel: $(uname -r)" | tee -a $RESULTS_FILE
echo "Starting OVS selinux package: $STARTING_RPM_OVS_SELINUX_EXTRA_POLICY_RPM" | tee -a $RESULTS_FILE
echo "Starting OVS package: $STARTING_RPM_OVS_RPM" | tee -a $RESULTS_FILE
echo "OVS package under test: $RPM_OVS_RPM" | tee -a $RESULTS_FILE
echo "OVS target version: $ovs_target_version" | tee -a $RESULTS_FILE
echo "OVS latest stream change package under test: $OVS_LATEST_STREAM_PKG_RPM" | tee -a $RESULTS_FILE
echo "The latest OVS stream is: $ovs_stream" | tee -a $RESULTS_FILE
echo "===========================================================================" | tee -a $RESULTS_FILE
sleep 3

$pkg_cmd -y install $STARTING_RPM_OVS_SELINUX_EXTRA_POLICY
wait
$pkg_cmd -y install $STARTING_RPM_OVS
wait

systemctl enable openvswitch && systemctl start openvswitch

starting_ovs_pkg=$(rpm -qa | grep openvswitch | grep -v selinux)
ovs-vsctl add-br $ovsbr
add_flows $ovsbr > /dev/null

num_flows1=$(ovs-ofctl dump-flows $ovsbr | wc -l)

pid1=$(systemctl status openvswitch | grep PID | awk '{print $3}')


echo "" | tee -a $RESULTS_FILE
echo "=============================== TEST RESULTS ==============================" | tee -a $RESULTS_FILE
	
$pkg_cmd -y update $RPM_OVS
sleep 2

ending_ovs_pkg=$(rpm -qa | grep openvswitch | grep -v selinux)
echo ""  | tee -a $RESULTS_FILE
echo "TEST: Verify that openvswitch RPM was upgraded as expected" | tee -a $RESULTS_FILE
if [[ "$starting_ovs_pkg" == "$ending_ovs_pkg" ]]; then
	echo "FAIL: OVS package was not upgraded" | tee -a $RESULTS_FILE
else
	echo "PASS: OVS package was successfully upgraded" | tee -a $RESULTS_FILE
fi

echo ""  | tee -a $RESULTS_FILE
echo "TEST: Verify that openvswitch does not restart when package is upgraded" | tee -a $RESULTS_FILE
pid2=$(systemctl status openvswitch | grep PID | awk '{print $3}')
if [[ $pid1 == $pid2 ]]; then
	echo "PASS: openvswitch did not restart" | tee -a $RESULTS_FILE
else
	echo "FAIL: openvswitch did restart" | tee -a $RESULTS_FILE
fi

echo ""  | tee -a $RESULTS_FILE
echo "TEST: Verify that all flows are intact after package is upgraded" | tee -a $RESULTS_FILE
num_flows2=$(ovs-ofctl dump-flows $ovsbr | wc -l)
if [[ $num_flows1 == $num_flows2 ]]; then
	echo "PASS: All $num_flows2 flows intact" | tee -a $RESULTS_FILE
else
	echo "FAIL: Flows are not intact" | tee -a $RESULTS_FILE
fi

reload_openvswitch_test

echo ""  | tee -a $RESULTS_FILE
echo "TEST: Verify that all flows are intact after service is reloaded and running version is upgraded" | tee -a $RESULTS_FILE
num_flows3=$(ovs-ofctl dump-flows $ovsbr | wc -l)
if [[ $num_flows1 == $num_flows3 ]]; then
	echo "PASS: All $num_flows3 flows intact" | tee -a $RESULTS_FILE
else
	echo "FAIL: Flows are not intact" | tee -a $RESULTS_FILE
fi

# Test to make sure direct upgrade to different stream package fails
get_ovs_stream
get_ovs_running_version

if [[ $ovs_stream == $ovs_running_version_short ]]; then
	echo ""  | tee -a $RESULTS_FILE
	echo "Skipping tests for stream change since OVS running version stream and new stream are the same" | tee -a $RESULTS_FILE
	echo ""  | tee -a $RESULTS_FILE
	echo ""  | tee -a $RESULTS_FILE
	if [[ $(grep -w FAIL $RESULTS_FILE) ]]; then
		echo "Overall test result: FAIL" | tee -a $RESULTS_FILE
	else
		echo "Overall test result: PASS" | tee -a $RESULTS_FILE
	fi
	echo "===========================================================================" | tee -a $RESULTS_FILE
	scp -o "StrictHostKeyChecking no" $RESULTS_FILE root@netqe-infra01.knqe.lab.eng.bos.redhat.com:/home/www/html/ovs_upgrade_test_results/$FDP_RELEASE/
	exit 0
else

	# test OVS stream change without wrapper file available
	sed -i 's/enabled=1/enabled=0/g' /etc/yum.repos.d/mylocalrepo.repo
	#$pkg_cmd -y update $OVS_LATEST_STREAM_PKG
	$pkg_cmd -y update openvswitch$ovs_stream
	
	echo ""  | tee -a $RESULTS_FILE
	echo "TEST: Verify that openvswitch stream change without wrapper file is blocked as expected" | tee -a $RESULTS_FILE
	rpm -q $(echo $OVS_LATEST_STREAM_PKG | awk -F "/" '{print $NF}' | awk -F "-" '{print $1}')
	if [[ $? -eq 1 ]]; then
		echo "PASS: openvswitch update stream change was blocked as expected" | tee -a $RESULTS_FILE
	else
		echo "FAIL: openvswitch update stream change was NOT blocked as expected" | tee -a $RESULTS_FILE
	fi
fi

# test OVS stream change with wrapper file available
sed -i 's/enabled=0/enabled=1/g' /etc/yum.repos.d/mylocalrepo.repo

$pkg_cmd -y update product-openvswitch
systemctl restart openvswitch
get_ovs_stream
get_ovs_running_version

echo ""  | tee -a $RESULTS_FILE
echo "TEST: Verify that openvswitch stream change with wrapper file is successful" | tee -a $RESULTS_FILE
if [[ $ovs_stream == $ovs_running_version_short ]]; then
	echo "PASS: OVS stream change was successful" | tee -a $RESULTS_FILE
else
	echo "FAIL: OVS stream change was NOT successful" | tee -a $RESULTS_FILE
fi	

echo ""  | tee -a $RESULTS_FILE
echo ""  | tee -a $RESULTS_FILE

total_failures=$(grep FAIL $RESULTS_FILE | wc -l)

echo "TOTAL FAILURES: $total_failures" | tee -a $RESULTS_FILE 

if [[ $total_failures -eq 0 ]]; then
	echo "Overall test result: PASS" | tee -a $RESULTS_FILE
else
	echo "Overall test result: FAIL" | tee -a $RESULTS_FILE
fi
echo "===========================================================================" | tee -a $RESULTS_FILE

scp -o "StrictHostKeyChecking no" $RESULTS_FILE root@netqe-infra01.knqe.lab.eng.bos.redhat.com:/home/www/html/ovs_upgrade_test_results/$FDP_RELEASE/

