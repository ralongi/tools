#!/bin/bash

$dbg_flag
machine=$1
if [[ $machine ]]; then
	echo "Returning $machine to beaker..."
	ssh root@"$machine" return2beaker.sh
else
	rm -f ~/stable_systems.txt
	bkr job-list --mine --w "Stable system" --unfinished  > ~/stable_jobs.txt
	bkr job-list --mine --w "tasks on" --unfinished >> ~/stable_jobs.txt
	bkr job-list --mine --w "Reserve RHEL" --unfinished  >> ~/stable_jobs.txt
	job_list=$(cat ~/stable_jobs.txt | tr -d '[",]')
	for i in $job_list; do 
		system_name=$(bkr job-results "$i" --prettyxml | grep 'system value' | tail -1 | awk -F'"' '{print $2}')
		echo "$system_name" | tee -a ~/stable_systems.txt
	done

	p=$(cat ~/stable_systems.txt | wc -l)

	pssh -O StrictHostKeyChecking=no -p $p -h ~/stable_systems.txt -t 0 -l root return2beaker.sh > /dev/null
fi











$dbg_flag
machine=$1

rm -f ~/stable_systems.txt
bkr job-list --mine --w "Stable system" --w "tasks on" --unfinished > ~/stable_jobs.txt
job_list=$(cat ~/stable_jobs.txt | tr -d '[",]')
for i in $job_list; do 
	system_name=$(bkr job-results "$i" --prettyxml | grep 'system value' | tail -1 | awk -F'"' '{print $2}')
	echo "$system_name" | tee -a ~/stable_systems.txt
done

p=$(cat ~/stable_systems.txt | wc -l)

pssh -O StrictHostKeyChecking=no -p $p -h ~/stable_systems.txt -t 0 -l root return2beaker.sh > /dev/null
