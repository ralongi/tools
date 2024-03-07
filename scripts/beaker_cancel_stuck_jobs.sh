#!/bin/bash

$dbg_flag

rm -f ~/temp/running_jobs.txt
bkr job-list --mine  --unfinished > ~/temp/running_jobs.txt
running_job_list=$(cat ~/temp/running_jobs.txt | tr -d '[",]]')
if [[ -z $running_job_list ]]; then
	echo "There are no running jobs.  Exiting..."
	exit 0
fi

for i in $running_job_list; do
	if [[ $(bkr job-results --no-logs --prettyxml $i | grep Stable) ]]; then
		export running_job_list=$(echo $running_job_list | sed -e "s/ $i//g")
	fi
	#if [[ $i == $(echo $running_job_list | awk '{print $1}') ]]; then
	#	export running_job_list=$(echo $running_job_list | sed -e "s/$i //g")
	#fi
	#if [[ $i == $(echo $running_job_list | awk '{print $1}') ]]; then
	#	export running_job_list=$(echo $running_job_list | sed -e "s/$i//g")
	#fi		
done	 

echo "Running jobs: $running_job_list"
for i in $running_job_list; do
	#bkr job-results --no-logs --prettyxml $i | grep task | grep 'status=' | awk '{print $7}' | grep -v openvswitch | awk -F '"' '{print $2}' > ~/temp/bkr_results.txt
	bkr job-results --no-logs --prettyxml $i | grep task | grep 'status=' | awk -F 'status=' '{print $2}' | awk '{print $1}' > ~/temp/bkr_results.txt
	if [[ ! $(grep -v Completed ~/temp/bkr_results.txt) ]]; then
		echo "Cancelling stuck beaker job: $i"
		bkr job-cancel $i
	else
		echo "Job ID $i is not stuck"
	fi
	rm -f ~/temp/bkr_results.txt
done
