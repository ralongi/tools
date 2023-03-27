#!/bin/bash

#set -x

# This script checks for any Fail/Panic/Warn test result for my tests run against a given FDP release.
# If $last_job_id value is provided via something like "export last_job_id=6895521" then the script will ignore any Job IDs preceding or equal to $last_job_id

pushd ~/temp
fdp_release=$1
if [[ $# -lt 1 ]]; then
	echo "Please provide the FDP release (i.e. 22g)"
	exit 0
fi
fdp_release=$(echo $fdp_release | tr '[:lower:]' '[:upper:]')
result_file="$fdp_release"_results.txt
rm -f $result_file
last_job_id=${last_job_id:-""}
skip_job_list=${skip_job_list:-""}

bkr job-list --mine -w "$fdp_release" | tr -d '",' > "$fdp_release"_job_list.txt
bkr job-list --mine -w "$fdp_release" --finished | tr -d '",' > "$fdp_release"_finished_job_list.txt
sed -i 's/\[//g; s/\]//g' "$fdp_release"_job_list.txt
sed -i 's/\[//g; s/\]//g' "$fdp_release"_finished_job_list.txt
total_jobs=$(cat "$fdp_release"_job_list.txt | wc -w)
finished_jobs=$(cat "$fdp_release"_finished_job_list.txt | wc -w)
echo ""
echo "Total jobs scheduled for $fdp_release: $total_jobs"
echo ""
echo "Total completed jobs for $fdp_release: $finished_jobs"

job_list=$(cat "$fdp_release"_job_list.txt)
finished_job_list=$(cat "$fdp_release"_finished_job_list.txt)

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
	
	if [[ $job_result == "Fail" ]] || [[ $job_result == "Panic" ]] && [[ ! $(bkr job-results $i --prettyxml | grep 'status="Cancelled"') ]] && [[ ! $(echo $skip_job_list | grep $i) ]] || [[ $(echo "$task_name" | egrep 'power-cycle|crash') ]] && [[ $(bkr job-results $i --prettyxml | grep 'result="Fail"') ]]; then
		if [[ $last_job_id ]]; then
			last_job_id=$(echo $last_job_id | tr -d "J:")
			if [[ $(echo $i | tr -d "J:") -gt $last_job_id ]]; then
				echo "" | tee -a $result_file
				echo "Job ID: $i" | tee -a $result_file
				echo "Status: $job_status" | tee -a $result_file
				echo "Result: $job_result" | tee -a $result_file
				echo "Job Link: https://beaker.engineering.redhat.com/jobs/$(echo $i | tr -d 'J:')" | tee -a $result_file
				echo "Task: $task_name" | tee -a $result_file
				echo "Compose: $compose" | tee -a $result_file
				echo "OVS RPM: $ovs_rpm_name" | tee -a $result_file
				echo "Failed tests:"  | tee -a $result_file
				echo $failed_tests  | tee -a $result_file
			elif [[ $(echo $i | tr -d "J:") -le $last_job_id ]]; then
				echo "Completed parsing results for JOB IDs greater than J:$last_job_id"
				break
			fi
		else
			echo "" | tee -a $result_file
			echo "Job ID: $i" | tee -a $result_file
			echo "Status: $job_status" | tee -a $result_file
			echo "Result: $job_result" | tee -a $result_file
			echo "Job Link: https://beaker.engineering.redhat.com/jobs/$(echo $i | tr -d 'J:')" | tee -a $result_file
			echo "Task: $task_name" | tee -a $result_file
			echo "Compose: $compose" | tee -a $result_file
			echo "OVS RPM: $ovs_rpm_name" | tee -a $result_file
			echo "Failed tests:"  | tee -a $result_file
			echo $failed_tests  | tee -a $result_file
		fi
	fi
done

total_tests=$(cat "$fdp_release"_job_list.txt| awk '{print NF}')
tests_not_passed=$(grep 'Job ID:' $result_file | wc -l)

echo ""
echo "Total jobs scheduled for $fdp_release: $total_jobs"
echo ""
echo "Total jobs finished for $fdp_release: $finished_jobs"
echo ""
echo "$tests_not_passed out of $finished_jobs total tests run resulted in Fail, Panic or Warn"
echo ""
echo "Results may be found in: ~/temp/$result_file"
echo ""
echo "Output of $result_file:"
echo ""
cat ~/temp/$result_file
echo ""
echo "Below is a list of the resulting job links to investigate:"
echo ""
grep -A3 'Job Link' $result_file
#grep -A2 'Failed tests' $result_file
echo ""
popd

