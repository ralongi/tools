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
bkr job-clone J:$job_id > new_job.log
new_job_id=$(grep Submitted new_job.log | awk -F "'" {'print $2}')
job_wb=$(bkr job-results $new_job_id | grep '<whiteboard>' | awk -F '<whiteboard>' '{print $2}' | awk -F '</whiteboard>' '{print $1}')
job_wb+=" \`Re-run of J:$job_id\`"
bkr job-modify $new_job_id --whiteboard="$job_wb"
popd
