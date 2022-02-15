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

ovsbr="ovsbr0"
flow_start=${flow_start:-"1"}
flow_end=${flow_end:-"1000"}
flows_file="/home/$ovsbr"_flows.txt
create_many_flows=${create_many_flows:-"yes"}
skip_upload=${skip_upload:-"no"}

source ../common/package_list.sh

FDP_RELEASE=${FDP_RELEASE:-""}
RPM_OVS=${RPM_OVS:-""}
STARTING_RPM_OVS_SELINUX_EXTRA_POLICY=${STARTING_RPM_OVS_SELINUX_EXTRA_POLICY:-""}
STARTING_RPM_OVS=${STARTING_RPM_OVS:-""}
OVS_LATEST_STREAM_PKG=${OVS_LATEST_STREAM_PKG:-""}
STARTING_RPM_OVS_SELINUX_EXTRA_POLICY_RPM=$(echo $STARTING_RPM_OVS_SELINUX_EXTRA_POLICY | awk -F "/" '{print $NF}')
STARTING_RPM_OVS_RPM=$(echo $STARTING_RPM_OVS | awk -F "/" '{print $NF}')
RPM_OVS_RPM=$(echo $RPM_OVS | awk -F "/" '{print $NF}')

STARTING_RPM_OVS_SELINUX_EXTRA_POLICY=${STARTING_RPM_OVS_SELINUX_EXTRA_POLICY:-""}
STARTING_RPM_OVS=${STARTING_RPM_OVS:-""}
STARTING_RPM_OVS_SELINUX_EXTRA_POLICY_RPM=$(echo $STARTING_RPM_OVS_SELINUX_EXTRA_POLICY | awk -F "/" '{print $NF}')
STARTING_RPM_OVS_RPM=$(echo $STARTING_RPM_OVS | awk -F "/" '{print $NF}')
OVS_LATEST_STREAM_PKG_RPM=$(echo $OVS_LATEST_STREAM_PKG | awk -F "/" '{print $NF}')

RPM_OVS_RPM=$(echo $RPM_OVS | awk -F "/" '{print $NF}')
RESULTS_FILE=$FDP_RELEASE"_"$STARTING_RPM_OVS_RPM"_"$RPM_OVS_RPM"_results.txt"

rm -f $RESULTS_FILE  && touch $RESULTS_FILE

if [[ $STARTING_RPM_OVS_RPM == $RPM_OVS_RPM ]] || [[ $STARTING_RPM_OVS_RPM == $OVS_LATEST_STREAM_PKG_RPM ]]; then
	rlLog "Skipping this test as starting and ending OVS packages are the same" | tee -a $RESULTS_FILE
	exit 0
fi

rpm -q yum-utils
if [[ $? != 0 ]]; then $pkg_cmd -y install $pkg_cmd-utils; fi
yum-complete-transaction --cleanup-only

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
	else
		rlLog "openvswitch is not installed so no cleanup necessary"
	fi
}

add_flows()
{
	$dbg_flag
	target_bridge=$1
	if [[ $# -lt 1 ]]; then target_bridge=$ovsbr; fi
	
	# delete any existing flows
	rlRun "ovs-ofctl del-flows $target_bridge"
	
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
    rlRun "ovs-ofctl add-flows $target_bridge $flows_file"
    rlRun "ovs-ofctl dump-flows $target_bridge"
}

confirm_ovs_active_status()
{
	if [[ $(systemctl is-active openvswitch) != "active" ]]; then
		rlFail "FAIL: openvswitch.service did not start as expected." | tee -a $RESULTS_FILE
			journalctl -xe
			exit 1
	else
		rlPass "PASS: openvswitch.service started/restarted/reloaded successfully." | tee -a $RESULTS_FILE
	fi
}

reload_openvswitch_test()
{
	$dbg_flag
	rlLog "Reloading openvswitch.service (flows should not be impacted)..."
	SECONDS=0
	#{ time systemctl reload openvswitch 2>1 ; } 2> time.log
	#restart_time=$(grep real time.log | awk '{print $2}')
	echo ""  | tee -a $RESULTS_FILE
	rlLog "TEST: Verify that openvswitch.service successfully reloaded" | tee -a $RESULTS_FILE
	rlRun "systemctl reload openvswitch"
	if [[ $(systemctl status openvswitch | grep "ovs-systemd-reload" | grep SUCCESS) ]]; then
		rlPass "PASS: openvswitch successfully reloaded" | tee -a $RESULTS_FILE
	else
		rlFail "FAIL: openvswitch did NOT reload as expected" | tee -a $RESULTS_FILE
		return 1
	fi
	echo ""  | tee -a $RESULTS_FILE
	rlLog "TEST: Verify that openvswitch.service reloaded in 2 seconds or less" | tee -a $RESULTS_FILE
	rlLog "Time to complete openvswitch.service restart/reload: $SECONDS second(s)" | tee -a $RESULTS_FILE
	if [[ $SECONDS -le 2 ]]; then
		rlPass "PASS: Restart time was acceptable" | tee -a $RESULTS_FILE
	else
		rlFail "FAIL: Restart time was NOT acceptable" | tee -a $RESULTS_FILE
	fi

	ovs_status=$(systemctl is-active openvswitch.service)
	get_ovs_running_version
	#get_ovs_target_version
	echo ""  | tee -a $RESULTS_FILE
	rlLog "TEST: Verify that openvswitch.service is running/active" | tee -a $RESULTS_FILE
	if [[ $ovs_status != "active" ]]; then
		rlFail "FAIL: openvswitch.service did not start as expected" | tee -a $RESULTS_FILE
		exit 1
	else
		rlPass "PASS: openvswitch.service is running as expected" | tee -a $RESULTS_FILE
		echo ""  | tee -a $RESULTS_FILE
		rlLog "TEST: Verify that openvswitch running version was upgraded as expected" | tee -a $RESULTS_FILE
		if [[ $ovs_running_version == $ovs_target_version ]]; then
			rlPass "PASS: It appears that the OVS running version upgrade was SUCCESSFUL" | tee -a $RESULTS_FILE
		else
			rlFail "FAIL: It appears that the OVS running version upgrade FAILED" | tee -a $RESULTS_FILE
		fi			
	fi
}

get_ovs_running_version()
{
	$dbg_flag
	installed_openvswitch_package=$(rpm -qa | grep openvswitch | egrep -v 'selinux|product')
	ovs_running_version=$(ovs-vsctl show | grep -m 1 ovs_version | awk '{print $2}' | tr -d '"')
	if [[ $ovs_running_version ]]; then
		rlLog "Running OVS version: $ovs_running_version"
		ovs_running_version_short=$( echo $ovs_running_version | awk -F "." '{print $1"."$2}')	
	elif [[ -z $ovs_running_version ]]; then
		ovs_running_version=$(ovs-vsctl --version | grep -m 1 ovs-vsctl | awk '{print $NF}')
		ovs_running_version_short=$( echo $ovs_running_version | awk -F "." '{print $1"."$2}')
		rlLog "OVS service does not appear to be running.  Installed openvswitch package is: $installed_openvswitch_package"
	fi
}

get_ovs_target_version()
{
	$dbg_flag
	$pkg_cmd -y install $STARTING_RPM_OVS_SELINUX_EXTRA_POLICY $RPM_OVS
	rlRun "systemctl start openvswitch"
	sleep 3
	#ovs_target_version=$(echo $RPM_OVS | awk -F "/" '{print $7}')
	ovs_target_version=$(ovs-vsctl show | grep -m 1 ovs_version | awk '{print $2}' | tr -d '"')
	rlRun "systemctl stop openvswitch"
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
        rlLog "OVS stream is: $ovs_stream"
}

create_local_upgrade_repo()
{
	$dbg_flag
	rlLog "RHEL VERSION is: $rhel_version"
	rlLog "The OVS stream is: $ovs_stream"
	today_date=$(date "+%a %b %d %Y")
	openvswitch_rpm_name=$(echo $OVS_LATEST_STREAM_PKG | awk -F "/" '{print $NF}')
	if [[ ! $(echo $openvswitch_rpm_name | awk -F "." '{print $5}' | egrep 'el7fdp|el8fdp') ]]; then
		openvswitch_rpm_name=$(echo  $openvswitch_rpm_name | awk -F "." '{print $1"."$2"."$3"."$4"."$6"."$7"."$8}')
	fi
	rm -f /etc/yum.repos.d/mylocalrepo.repo 
	rm -Rf /tmp/mylocalrepo
	get_ovs_stream
	rlRun "$pkg_cmd -y install wget"
	rlRun "$pkg_cmd -y install rpm-build"
	rlRun "$pkg_cmd -y install createrepo"
	if [[ ! -e ~/rpmbuild/SPECS ]]; then mkdir -p ~/rpmbuild/SPECS; fi
	rm -f ~/rpmbuild/SPECS/product-openvswitch.spec
	rlRun "wget -q -O ~/rpmbuild/SPECS/product-openvswitch.spec http://netqe-infra01.knqe.lab.eng.bos.redhat.com/misc/product-openvswitch.spec"
	rlRun "sed -i "s/ovs_stream/$ovs_stream/g" ~/rpmbuild/SPECS/product-openvswitch.spec"
	rlRun "sed -i "s/today_date/$today_date/g" ~/rpmbuild/SPECS/product-openvswitch.spec"

	rpmbuild -ba ~/rpmbuild/SPECS/product-openvswitch.spec
	if [[ ! -e /tmp/mylocalrepo ]]; then mkdir /tmp/mylocalrepo; fi
	if [[ ! -e /tmp/mylocalrepo/Packages ]]; then mkdir /tmp/mylocalrepo/Packages; fi
	rlRun "rm -f /tmp/mylocalrepo/Packages/*"

	rlRun "/bin/cp -f ~/rpmbuild/RPMS/noarch/product-openvswitch*.rpm /tmp/mylocalrepo/Packages"
	rlRun "wget -q -O /tmp/mylocalrepo/Packages/$openvswitch_rpm_name $OVS_LATEST_STREAM_PKG"
	rlRun "createrepo /tmp/mylocalrepo"

	cat <<-EOF > /etc/yum.repos.d/mylocalrepo.repo
		[mylocalrepo]
		name=mylocalrepo
		baseurl=file:///tmp/mylocalrepo
		enabled=1
		gpgcheck=0
	EOF

	rlRun "yum clean all expire-cache"
	rlRun "rm -rf /var/cache/yum"
	sleep 5

	rlRun "$pkg_cmd info product-openvswitch"
	rlRun "$pkg_cmd info openvswitch$ovs_stream"
}

rlJournalStart
if [ -z "$JOBID" ]; then
        echo "Variable jobid not set! Assume developer mode."
fi

	rlPhaseStartSetup "Set up initial environment"
		rlRun "cleanup_ovs"
		rlRun "get_ovs_target_version"
		rlRun "cleanup_ovs"
		rlRun "get_ovs_stream"
		rlRun "create_local_upgrade_repo"

		compose_id=$(grep 'server='  /root/anaconda-ks.cfg | awk -F "/" '{print $(NF-5)}')

		echo "===========================================================================" | tee -a $RESULTS_FILE
		rlLog "Package Info:" | tee -a $RESULTS_FILE
		rlLog "RHEL VERSION: $rhel_version" | tee -a $RESULTS_FILE
		rlLog "RHEL Compose: $compose_id" | tee -a $RESULTS_FILE
		rlLog "Kernel: $(uname -r)" | tee -a $RESULTS_FILE
		rlLog "Starting OVS selinux package: $STARTING_RPM_OVS_SELINUX_EXTRA_POLICY_RPM" | tee -a $RESULTS_FILE
		rlLog "Starting OVS package: $STARTING_RPM_OVS_RPM" | tee -a $RESULTS_FILE
		rlLog "OVS package under test: $RPM_OVS_RPM" | tee -a $RESULTS_FILE
		rlLog "OVS target version: $ovs_target_version" | tee -a $RESULTS_FILE
		rlLog "OVS latest stream change package under test: $OVS_LATEST_STREAM_PKG_RPM" | tee -a $RESULTS_FILE
		rlLog "The latest OVS stream is: $ovs_stream" | tee -a $RESULTS_FILE
		echo "===========================================================================" | tee -a $RESULTS_FILE

		rlRun "$pkg_cmd -y install $STARTING_RPM_OVS_SELINUX_EXTRA_POLICY"
		wait
		rlRun "$pkg_cmd -y install $STARTING_RPM_OVS"
		wait
	rlPhaseEnd
	
	rlPhaseStartTest "Run OVS USER and GROUP Test"
		echo "" | tee -a $RESULTS_FILE
		echo "=============================== TEST RESULTS ==============================" | tee -a $RESULTS_FILE

		OVS_USER_ID_SETTING=$(grep OVS_USER_ID /etc/sysconfig/openvswitch | awk -F "=" '{print $NF}' | tr -d '"')
		rlLog "OVS_USER_ID setting in /etc/sysconfig/openvswitch: $OVS_USER_ID_SETTING" | tee -a $RESULTS_FILE
		if [[ $OVS_USER_ID_SETTING != "openvswitch:hugetlbfs" ]]; then
			rlLogWarning "WARN: OVS_USER_ID setting in /etc/sysconfig/openvswitch is not 'openvswitch:hugetlbfs'" | tee -a $RESULTS_FILE
		fi

		rlLog "Check USER and GROUP setting for /var/log/openvswitch before starting openvswitch.service"
		expected_user_id=$(echo $OVS_USER_ID_SETTING | awk -F":" '{print $1}')
		expected_group_id=$(echo $OVS_USER_ID_SETTING | awk -F":" '{print $2}')

		USER=$(stat -c '%U' /var/log/openvswitch)
		GROUP=$(stat -c '%G' /var/log/openvswitch)
		if [[ $USER == "openvswitch" ]] && [[ $GROUP == "openvswitch" ]]; then
			rlPass "PASS: USER ($USER) and GROUP ($GROUP) values for /var/log/openvswitch (before service start) are correct" | tee -a $RESULTS_FILE
		else
			rlFail "FAIL: USER ($USER) and GROUP ($GROUP) values for /var/log/openvswitch (before service start) are NOT correct" | tee -a $RESULTS_FILE
		fi

		rlLog "Check USER and GROUP setting for /var/log/openvswitch after starting openvswitch.service"
		rlRun "systemctl enable openvswitch && systemctl start openvswitch"

		USER=$(stat -c '%U' /var/log/openvswitch)
		GROUP=$(stat -c '%G' /var/log/openvswitch)
		if [[ $USER == $expected_user_id ]] && [[ $GROUP == $expected_group_id ]]; then
			rlPass "PASS: USER ($USER) and GROUP ($GROUP) values for /var/log/openvswitch (after service start) are correct" | tee -a $RESULTS_FILE
		else
			rlFail "FAIL: USER ($USER) and GROUP ($GROUP) values for /var/log/openvswitch (after service start) are NOT correct" | tee -a $RESULTS_FILE
		fi
	rlPhaseEnd

	rlPhaseStartTest "Test package update"
		starting_ovs_pkg=$(rpm -qa | grep openvswitch | grep -v selinux)
		rlRun "ovs-vsctl add-br $ovsbr"
		rlRun "add_flows $ovsbr > /dev/null"

		num_flows1=$(ovs-ofctl dump-flows $ovsbr | wc -l)

		pid1=$(systemctl status openvswitch | grep PID | awk '{print $3}')
			
		rlRun "$pkg_cmd -y update $RPM_OVS"
		sleep 2

		ending_ovs_pkg=$(rpm -qa | grep openvswitch | grep -v selinux)
		echo ""  | tee -a $RESULTS_FILE
		rlLog "TEST: Verify that openvswitch RPM was upgraded as expected" | tee -a $RESULTS_FILE
		if [[ "$starting_ovs_pkg" == "$ending_ovs_pkg" ]]; then
			rlFail "FAIL: OVS package was not upgraded" | tee -a $RESULTS_FILE
		else
			rlPass "PASS: OVS package was successfully upgraded" | tee -a $RESULTS_FILE
		fi

		OVS_USER_ID_SETTING=$(grep OVS_USER_ID /etc/sysconfig/openvswitch | awk -F "=" '{print $NF}' | tr -d '"')
		rlog "OVS_USER_ID setting in /etc/sysconfig/openvswitch: $OVS_USER_ID_SETTING" | tee -a $RESULTS_FILE
		if [[ $OVS_USER_ID_SETTING != "openvswitch:hugetlbfs" ]]; then
			rlLogWarning "WARN: OVS_USER_ID setting in /etc/sysconfig/openvswitch is not 'openvswitch:hugetlbfs'" | tee -a $RESULTS_FILE
		fi

		expected_user_id=$(echo $OVS_USER_ID_SETTING | awk -F":" '{print $1}')
		expected_group_id=$(echo $OVS_USER_ID_SETTING | awk -F":" '{print $2}')
		USER=$(stat -c '%U' /var/log/openvswitch)
		GROUP=$(stat -c '%G' /var/log/openvswitch)
		if [[ $USER == $expected_user_id ]] && [[ $GROUP == $expected_group_id ]]; then
			rlPass "PASS: USER ($USER) and GROUP ($GROUP) values for /var/log/openvswitch (after package update) are correct" | tee -a $RESULTS_FILE
		else
			rlFail "FAIL: USER ($USER) and GROUP ($GROUP) values for /var/log/openvswitch (after package update) are NOT correct" | tee -a $RESULTS_FILE
		fi
	rlPhaseEnd

	rlPhaseStartTest "Verify that openvswitch does not restart when package is upgraded"
		echo ""  | tee -a $RESULTS_FILE
		rlLog "TEST: Verify that openvswitch does not restart when package is upgraded" | tee -a $RESULTS_FILE
		pid2=$(systemctl status openvswitch | grep PID | awk '{print $3}')
		if [[ $pid1 == $pid2 ]]; then
			rlPass "PASS: openvswitch did not restart" | tee -a $RESULTS_FILE
		else
			rlFail "FAIL: openvswitch did restart" | tee -a $RESULTS_FILE
		fi
	rlPhaseEnd

	rlPhaseStartTest "Verify that all flows are intact after package is upgraded"
		echo ""  | tee -a $RESULTS_FILE
		rlLog "TEST: Verify that all flows are intact after package is upgraded" | tee -a $RESULTS_FILE
		num_flows2=$(ovs-ofctl dump-flows $ovsbr | wc -l)
		if [[ $num_flows1 == $num_flows2 ]]; then
			rlPass "PASS: All $num_flows2 flows intact" | tee -a $RESULTS_FILE
		else
			rlFail "FAIL: Flows are not intact" | tee -a $RESULTS_FILE
		fi
	rlPhaseEnd

	rlPhaseStartTest "Verify that all flows are intact after service is reloaded and running version is upgraded"
		rlRun "reload_openvswitch_test"
		echo ""  | tee -a $RESULTS_FILE
		rlLog "TEST: Verify that all flows are intact after service is reloaded and running version is upgraded" | tee -a $RESULTS_FILE
		num_flows3=$(ovs-ofctl dump-flows $ovsbr | wc -l)
		if [[ $num_flows1 == $num_flows3 ]]; then
			rlPass "PASS: All $num_flows3 flows intact" | tee -a $RESULTS_FILE
		else
			rlFail "FAIL: Flows are not intact" | tee -a $RESULTS_FILE
		fi
	rlPhaseEnd

	rlPhaseStartTest "Verify that USER and GROUP values for /var/log/openvswitch (after service reload) are correct"
		USER=$(stat -c '%U' /var/log/openvswitch)
		GROUP=$(stat -c '%G' /var/log/openvswitch)
		if [[ $USER == $expected_user_id ]] && [[ $GROUP == $expected_group_id ]]; then
			rlPass "PASS: USER ($USER) and GROUP ($GROUP) values for /var/log/openvswitch (after service reload) are correct" | tee -a $RESULTS_FILE
		else
			rlFail "FAIL: USER ($USER) and GROUP ($GROUP) values for /var/log/openvswitch (after service reload) are NOT correct" | tee -a $RESULTS_FILE
		fi
	rlPhaseEnd

	rlPhaseStartTest "Verify that direct upgrade to different stream package fails"
		rlRun "get_ovs_stream"
		rlRun "get_ovs_running_version"

		if [[ $ovs_stream == $ovs_running_version_short ]]; then
			echo ""  | tee -a $RESULTS_FILE
			rlLog "Skipping tests for stream change since OVS running version stream and new stream are the same" | tee -a $RESULTS_FILE
			echo ""  | tee -a $RESULTS_FILE
			echo ""  | tee -a $RESULTS_FILE
			if [[ $(grep -w FAIL $RESULTS_FILE) ]]; then
				rlFail "Overall test result: FAIL" | tee -a $RESULTS_FILE
			else
				rlPass "Overall test result: PASS" | tee -a $RESULTS_FILE
			fi
			echo "===========================================================================" | tee -a $RESULTS_FILE
			rlPhaseEnd
			rhts_submit_log -l $RESULTS_FILE
			rlJournalPrintText
    		rlJournalEnd
		else
			rlPhaseStartTest "Verify that OVS stream change is blocked without wrapper file available"
				rlRun "sed -i 's/enabled=1/enabled=0/g' /etc/yum.repos.d/mylocalrepo.repo"
				rlRun "$pkg_cmd -y update openvswitch$ovs_stream"
				
				echo ""  | tee -a $RESULTS_FILE
				rlLog "TEST: Verify that openvswitch stream change without wrapper file is blocked as expected" | tee -a $RESULTS_FILE
				rpm -q $(echo $OVS_LATEST_STREAM_PKG | awk -F "/" '{print $NF}' | awk -F "-" '{print $1}')
				if [[ $? -eq 1 ]]; then
					rlPass "PASS: openvswitch update stream change was blocked as expected" | tee -a $RESULTS_FILE
				else
					rlFail "FAIL: openvswitch update stream change was NOT blocked as expected" | tee -a $RESULTS_FILE
				fi
			rlPhaseEnd
		fi
	
	rlPhaseStartTest "Verify that USER and GROUP settings for /var/log/openvswitch are still correct"
		USER=$(stat -c '%U' /var/log/openvswitch)
		GROUP=$(stat -c '%G' /var/log/openvswitch)
		if [[ $USER == $expected_user_id ]] && [[ $GROUP == $expected_group_id ]]; then
			rlPass "PASS: USER ($USER) and GROUP ($GROUP) values for /var/log/openvswitch are correct" | tee -a $RESULTS_FILE
		else
			rlFail "FAIL: USER ($USER) and GROUP ($GROUP) values for /var/log/openvswitch are NOT correct" | tee -a $RESULTS_FILE
		fi
	rlPhaseEnd

	rlPhaseStartTest "Verify that stream change is successful when wrapper file is available"
		rlRun "sed -i 's/enabled=0/enabled=1/g' /etc/yum.repos.d/mylocalrepo.repo"

		rlRun "$pkg_cmd -y update product-openvswitch"
		rlRun "systemctl restart openvswitch"
		rlRun "get_ovs_stream"
		rlRun "get_ovs_running_version"

		echo ""  | tee -a $RESULTS_FILE
		rlLog "TEST: Verify that openvswitch stream change with wrapper file is successful" | tee -a $RESULTS_FILE
		if [[ $ovs_stream == $ovs_running_version_short ]]; then
			rlPass "PASS: OVS stream change was successful" | tee -a $RESULTS_FILE
		else
			rlFail "FAIL: OVS stream change was NOT successful" | tee -a $RESULTS_FILE
		fi
	rlPhaseEnd

	rlPhaseStartTest "Verify that values for /var/log/openvswitch are correct after service restart"
		USER=$(stat -c '%U' /var/log/openvswitch)
		GROUP=$(stat -c '%G' /var/log/openvswitch)
		if [[ $USER == $expected_user_id ]] && [[ $GROUP == $expected_group_id ]]; then
			rlPass "PASS: USER ($USER) and GROUP ($GROUP) values for /var/log/openvswitch are correct" | tee -a $RESULTS_FILE
		else
			rlFail "FAIL: USER ($USER) and GROUP ($GROUP) values for /var/log/openvswitch are NOT correct" | tee -a $RESULTS_FILE
		fi
	rlPhaseEnd

rhts_submit_log -l $RESULTS_FILE
rlJournalPrintText
rlJournalEnd

