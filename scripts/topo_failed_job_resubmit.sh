#!/bin/bash

export dbg_flag=${dbg_flag:-"set +x"}
$dbg_flag

job_id=$1
if [[ $# -lt 1 ]]; then
	echo "Please provide a beaker job ID (minus the 'J:')"
	echo "Example: $0 9826827"
	exit 0
fi

pushd ~
old_compose=$(bkr job-results J:$job_id --prettyxml | grep DISTRO_BUILD | head -1 | awk -F '"' '{print $4}')
old_compose_ver=$(echo $old_compose | awk -F '-' '{print $2}' |  sed 's/.0//g')
/home/ralongi/github/tools/scripts/get_kernel_from_compose.sh $old_compose_ver
if [[ $? -ne 0 ]]; then
	/home/ralongi/github/tools/scripts/get_beaker_compose_id.sh $old_compose_ver
	new_compose=$(cat /tmp/new_compose_id.txt)
	#new_compose=$latest_compose_id
fi

log=$(bkr job-results J:$job_id --prettyxml | grep -A40 '"/kernel/networking/openvswitch/topo" role="CLIENTS"' | grep taskout.log | awk -F '"' '{print $2}')
result_file=$(basename $log)
wget --quiet -O $result_file $log
rm -f failed_tests.txt

if [[ $(grep rstrnt-report-result taskout.log) ]]; then
	for i in $(grep rstrnt-report-result taskout.log | grep FAIL | awk '{print $4}'); do
		echo $i | sed 's/-/_/g' >> failed_tests.txt
	done
elif [[ $(grep -i 'RESULT: FAIL' taskout.log) ]]; then # for when job aborted with failures
	for i in $(grep -i 'RESULT: FAIL' taskout.log | grep -v -i OVERALL | awk -F '(' '{print $NF}' | tr -d ')'); do
		echo $i | sed 's/-/_/g' >> failed_tests.txt
	done
else
	echo "There are no failed tests reported in taskout.log"
	exit 0
fi

original_ovs_topo=$(bkr job-clone J:$job_id --prettyxml --dryrun | grep '<param name="OVS_TOPO"' | awk -F '"' '{print $4}' | tail -1)
if [[ -z $new_ovs_topo ]]; then
	new_ovs_topo=$(cat failed_tests.txt)
	new_ovs_topo+='"'
	new_ovs_topo='"'$new_ovs_topo
	new_ovs_topo=$(echo $new_ovs_topo | dos2unix)
	new_ovs_topo=$(echo $new_ovs_topo | tr -d '"')
fi

bkr job-clone J:$job_id --prettyxml --dryrun > new_job.xml
sed -i "s/$original_ovs_topo/$new_ovs_topo/g" new_job.xml
if [[ $new_compose ]]; then sed -i "s/$old_compose/$new_compose/g" new_job.xml; fi
bkr job-submit new_job.xml | tee new_job.log
new_job_id=$(grep Submitted new_job.log | awk -F "'" {'print $2}')
job_wb=$(bkr job-results $new_job_id | grep '<whiteboard>' | awk -F '<whiteboard>' '{print $2}' | awk -F '</whiteboard>' '{print $1}')
job_wb+=" \`Re-run of J:$job_id\`"
bkr job-modify $new_job_id --whiteboard="$job_wb"
rm -f /tmp/new_compose_id.txt
popd



	
	


