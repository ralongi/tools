#!/bin/bash

$dbg_flag
extend_time=${extend_time:-"864000"}
#days=$((( $extend_time / 60 / 60 / 24 )))
machine=$1
if [[ $machine ]]; then
	echo "Reserve time on $machine being extended by $extend_time seconds"
	bkr watchdog-extend --by=$extend_time "$machine"
else
	bkr job-list --mine --w "Stable system" --w "tasks on" --unfinished > ~/stable_jobs.txt
	bkr job-list --mine --w "Reserve" --unfinished >> ~/stable_jobs.txt
	job_list=$(cat ~/stable_jobs.txt | tr -d '[",]')
	echo "Stable system jobs being extended by $extend_time seconds: $job_list"
	for i in $job_list; do 
		system_name=$(bkr job-results "$i" --prettyxml | grep 'system value' | tail -1 | awk -F'"' '{print $2}')
		bkr watchdog-extend --by=$extend_time "$system_name"
		echo "Time now remaining on $i: $(bkr job-results "$i" --prettyxml | grep 'Time Remaining' | awk -F 'Time Remaining' '{print $NF}' | tr -d '">')"
	done
fi
