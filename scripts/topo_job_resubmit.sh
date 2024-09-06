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
log=$(bkr job-results J:$job_id --prettyxml | grep -A40 '"/kernel/networking/openvswitch/topo" role="CLIENTS"' | grep taskout.log | awk -F '"' '{print $2}')
result_file=$(basename $log)
wget --quiet -O $result_file $log
rm -f failed_tests.txt
for i in $(grep rstrnt-report-result taskout.log | grep FAIL | awk '{print $4}'); do
	echo $i | sed 's/-/_/g' >> failed_tests.txt
done

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
bkr job-submit new_job.xml
popd



	
	


