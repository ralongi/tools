#!/bin/bash

$dbg_flag

# This script checks for test results for my tests run against a given whiteboard search criteria OR job ID.

if [[ "$*" == *"job="* ]]; then
	job_id=$(echo "$*" | awk -F 'job=' '{print $NF}')	
	job_result=$(bkr job-results J:$job_id --prettyxml | grep '<job id=' | awk '{print $4}' | awk -F "=" '{print $2}' | tr -d '"')
	compose=$(bkr job-results J:$job_id --prettyxml | grep distro_name | head -n1 | awk -F '"' '{print $4}')
	ovs_rpm_name=$(bkr job-results J:$job_id --prettyxml | grep -wi RPM_OVS | head -n1 | awk -F '/' '{print $(NF-1)}' | tr -d '"')
	#task_name=$(bkr job-results $i --prettyxml | grep 'task name=' | grep -v install | awk -F '"' '{print $2}')
	task_name=$(bkr job-results J:$job_id --prettyxml | grep 'task name=' | egrep -v 'distribution|install' | awk -F '"' '{print $2}')
	if [[ $(echo $task_name | awk '{print $1}') == $(echo $task_name | awk '{print $2}') ]]; then
		task_name=$(echo $task_name | awk '{print $1}')
	fi
	job_status=$(bkr job-results J:$job_id --prettyxml | grep 'job id' | awk '{print $5}' | awk -F "=" '{print $NF}' | tr -d '"')
	failed_tests=$(bkr job-results J:$job_id --prettyxml | grep 'result="Fail"' | grep path | awk '{print $2}' | awk -F "=" '{print $2}' | sort -u)
	
	echo ""
	echo "Job ID: J:$job_id"
	echo "Status: $job_status"
	echo "Job Link: https://beaker.engineering.redhat.com/jobs/$(echo $i | tr -d 'J:')"
	echo "Task: $task_name"
	echo "Compose: $compose"
	echo "OVS RPM: $ovs_rpm_name"
	echo "Result: $job_result"
	echo "Failed tests:"
	echo $failed_tests | tr -d '"' | sed 's/-/_/g' | tee -a $result_file
	echo ""
	
else
	pushd ~/temp
	wb_search_criteria=$1
	if [[ $# -lt 1 ]]; then
		echo "Please provide whiteboard search criteria (i.e. 22g, CTC2, 'FDP 23A, openvswitch2.13')"
		exit 0
	fi
	result_file="search_results.txt"
	rm -f $result_file

	bkr job-list --mine --whiteboard="$wb_search_criteria" > jobs.txt
	job_list=$(cat jobs.txt | tr -d '[",]]')

	bkr job-list --mine --whiteboard="$wb_search_criteria" --finished | tr -d '",' > finished_jobs.txt
	sed -i 's/\[//g; s/\]//g' jobs.txt
	sed -i 's/\[//g; s/\]//g' finished_jobs.txt
	total_jobs=$(cat jobs.txt | wc -w)
	finished_jobs=$(cat finished_jobs.txt | wc -w)
	echo ""
	echo "Total jobs scheduled for $wb_search_criteria: $total_jobs"
	echo ""
	echo "Total completed jobs for $wb_search_criteria: $finished_jobs"

	job_list=$(cat jobs.txt)
	finished_job_list=$(cat finished_jobs.txt)

	for i in $finished_job_list; do
		job_result=$(bkr job-results $i --prettyxml | grep '<job id=' | awk '{print $4}' | awk -F "=" '{print $2}' | tr -d '"')
		compose=$(bkr job-results $i --prettyxml | grep distro_name | head -n1 | awk -F '"' '{print $4}')
		ovs_rpm_name=$(bkr job-results $i --prettyxml | grep -wi RPM_OVS | head -n1 | awk -F '/' '{print $(NF-1)}' | tr -d '"')
		#task_name=$(bkr job-results $i --prettyxml | grep 'task name=' | grep -v install | awk -F '"' '{print $2}')
		task_name=$(bkr job-results $i --prettyxml | grep 'task name=' | egrep -v 'distribution|install' | awk -F '"' '{print $2}')
		if [[ $(echo $task_name | awk '{print $1}') == $(echo $task_name | awk '{print $2}') ]]; then
			task_name=$(echo $task_name | awk '{print $1}')
		fi
		job_status=$(bkr job-results $i --prettyxml | grep 'job id' | awk '{print $5}' | awk -F "=" '{print $NF}' | tr -d '"')
		failed_tests=$(bkr job-results $i --prettyxml | grep 'result="Fail"' | grep path | awk '{print $2}' | awk -F "=" '{print $2}' | sort -u)
		wb=$(bkr job-results $i --prettyxml | egrep '<whiteboard>|</whiteboard>')
		wb=$(echo $wb | sed 's/<whiteboard>//g' | sed 's/<\/whiteboard>//g')
		echo "" | tee -a $result_file
		echo "Job ID: $i" | tee -a $result_file 
		echo "Status: $job_status" | tee -a $result_file
		echo "Job Link: https://beaker.engineering.redhat.com/jobs/$(echo $i | tr -d 'J:')" | tee -a $result_file
		echo "Whiteboard: $wb" | tee -a $result_file
		echo "Task: $task_name" | tee -a $result_file
		echo "Compose: $compose" | tee -a $result_file
		echo "OVS RPM: $ovs_rpm_name" | tee -a $result_file
		echo "Result: $job_result" | tee -a $result_file
		echo "Failed tests:"  | tee -a $result_file
		echo $failed_tests | tr -d '"' | sed 's/-/_/g' | tee -a $result_file
	done

	total_tests=$(cat jobs.txt | awk '{print NF}')
	tests_not_passed=$(grep 'Job ID:' $result_file | wc -l)

	echo ""
	echo "Total jobs scheduled for $wb_search_criteria: $total_jobs"
	echo ""
	echo "Total jobs finished for $wb_search_criteria: $finished_jobs"
	echo ""
	echo "$tests_not_passed out of $finished_jobs total tests run resulted in Fail, Panic or Warn"
	echo ""
	echo "Results may be found in: ~/temp/$result_file"
	echo ""
	echo "Output of $result_file:"
	echo ""
	cat $result_file
	echo ""
	echo "$wb_search_criteria Jobs:"
	echo ""
	grep -A5 'Job Link' $result_file
	#grep -A2 'Failed tests' $result_file
	echo ""
fi
popd 2&> /dev/null

