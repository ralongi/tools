#!/bin/bash

$dbg_flag
job_id=$1
pass_fail_result_file=~/pass_fail.txt

if [[ -z $job_id ]]; then
	echo "Please provide the Beaker Job ID."
	echo "Example: $0 7768126"
	exit 0
fi

pushd ~
echo ""
echo "Checking results (this may take a while depending on the number of tests that were run)..."
echo ""

baseline_file=${baseline_file:-""}
rm -f test_results.txt full_test_names.txt taskout.log $pass_fail_result_file

sedeasy ()
{ 
	sed -i "s/$(echo $1 | sed -e 's/\([[\/.*]\|\]\)/\\&/g')/$(echo $2 | sed -e 's/[\/&]/\\&/g')/g" $3
}

get_results()
{
	$dbg_flag
	touch full_test_names.txt
	for tests in $tests_info; do
		declare -i field_count=$(echo $tests | awk -F '"' '{print NF-1}')
		declare -i count=2
		while [[ $count -le $field_count ]]; do
			test_name=$(echo $tests | awk -v count=$count -F '"' '{print $ count}')
			frame_size=$(grep -B8 "$test_name" $result_file | grep jq | grep sz | awk '{print $5}')
			field_count=$(echo $frame_size | wc -w)
			declare -i field=1; 
			while [[ $field -le $field_count ]]; do
				frame_size_new=$(echo $frame_size | awk -v field=$field '{print $ field}')
				full_test_name=$(echo $test_name"_"$frame_size_new)
				if [[ ! $(grep "$full_test_name" full_test_names.txt) ]]; then
					echo $full_test_name >> full_test_names.txt
					result=$(grep "$test_name" $result_file | grep result | awk -F "," '{print $2}' | awk -F '.' '{print $1}' | tr -d '",')
					result=$(echo $result | awk -v field=$field '{print $ field}')
					echo "$full_test_name=$result" >> test_results.txt
				fi
				field=$field+1
			done
			count=$count+2
		done
	done
}

calc_pass_fail()
{
	$dbg_flag
	declare -i pf_pct_baseline=${pf_pct_baseline:-"-10"}
	for i in $(cat test_results.txt); do
		test=$(echo $i | awk -F "=" '{print $1}')
		declare -i result=$(echo $i | awk -F "=" '{print $NF}')
		declare -i baseline=$(grep $test $baseline_file | awk -F "=" '{print $NF}')
		declare -i delta=$(($result - $baseline))
		pct=$(awk "BEGIN { pc=100*${delta}/${baseline}; i=int(pc); print (pc-i<0.5)?i:i+1 }")
		if [[ $pct -gt 0 ]]; then pct="+"$pct; fi
		echo $i >> $pass_fail_result_file
		if [[ $pct -ge $pf_pct_baseline ]]; then
			echo "Result: PASS	baseline: $baseline, Result: $result" >> $pass_fail_result_file
		else
			echo "Result: FAIL	baseline: $baseline, Result: $result" >> $pass_fail_result_file
		fi
		echo "Difference between actual result and baseline: $delta ($pct%)" >> $pass_fail_result_file
		echo "" >> $pass_fail_result_file
	done
}

dpdk_rpm=$(bkr job-results J:$job_id --prettyxml | grep -i rpm_dpdk | head -n1 | awk -F '/' '{print $(NF-1)}' | tr -d '"')
ovs_rpm=$(bkr job-results J:$job_id --prettyxml | grep -i rpm_ovs | head -n1 | awk -F '/' '{print $(NF-1)}' | tr -d '"')
compose=$(bkr job-results J:$job_id --prettyxml | grep -i distro_name | head -n1 | awk -F '"' '{print $(NF-1)}')
arch=$(bkr job-results J:$job_id --prettyxml | grep -i distro_arch | head -n1 | awk -F '"' '{print $(NF-1)}')
whiteboard=$(bkr job-results J:$job_id --prettyxml | grep '<whiteboard>' | awk -F '>' '{print $2}' | awk -F '<' '{print $1}')
log=$(bkr job-results J:$job_id --prettyxml | grep -A40 '"/kernel/networking/openvswitch/perf" role="CLIENTS"' | grep taskout.log | awk -F '"' '{print $2}')
html_result_file=$(bkr job-results J:$job_id --prettyxml | grep -A40 '"/kernel/networking/openvswitch/perf" role="CLIENTS"' | grep html | awk '{print $2}' | awk -F "=" '{print $2}' | sed 's/"//g')
result_file=$(basename $log)
rm -f $html_result_file $result_file $pass_fail_result_file
wget --quiet -O $result_file $log
kernel_id=$(grep kernel_version taskout.log | awk -F "=" '{print $NF}' | tail -n1)

strip_characters='+ = [[ ]] [ ] \[\] \\'
grep '\[\[\"' taskout.log | grep '"' | grep -v result > tests_info.txt
for character in $strip_characters; do sedeasy "$character" "" tests_info.txt; done
tests_info=$(cat tests_info.txt | tr -d " ")
frame_size_list="64 128 256 1500 2000 9200"
result_file=~/taskout.log

nic_model=$(grep -i '"nic_info":' taskout.log  | head -n1)
if [[ $(echo $nic_model | grep -i cx5) ]]; then
	baseline_file=~/github/tools/scripts/new_cx5_perf_ci_baseline.txt
elif [[ $(echo $nic_model | grep -i cx6) ]]; then
	baseline_file=~/github/tools/scripts/cx6_perf_ci_baseline.txt
fi

source $baseline_file

get_results
calc_pass_fail


## debug

set -x
echo "###############  DEBUG  ###############"

total_tests=$(grep -w 'Result:' $pass_fail_result_file | grep -vi Overall | wc -l)
total_failed_tests=$(grep -w 'Result: FAIL' $pass_fail_result_file | wc -l)

echo "" >> $pass_fail_result_file
if [[ $(grep -i fail $pass_fail_result_file) ]]; then	
	echo "Overall Result: $total_failed_tests of $total_tests tests FAILED"	>> $pass_fail_result_file
	echo "" >> $pass_fail_result_file
	echo "FAILED tests:" >> $pass_fail_result_file
	echo "" >> $pass_fail_result_file	
	grep -B1 -A1 'Result: FAIL' $pass_fail_result_file
else
	echo "Overall Result: All $total_tests tests PASSED" >> $pass_fail_result_file
fi

echo "" >> $pass_fail_result_file
echo "Summary:" >> $pass_fail_result_file
echo "" >> $pass_fail_result_file

if [[ $(grep -i fail $pass_fail_result_file) ]]; then
	echo "Overall Result: $total_failed_tests of $total_tests tests FAILED"	>> $pass_fail_result_file
else
	echo "Overall Result: All $total_tests tests PASSED" >> $pass_fail_result_file
fi

echo "Compose: $compose" >> $pass_fail_result_file
echo "OVS RPM: $ovs_rpm" >> $pass_fail_result_file
echo "DPDK RPM: $dpdk_rpm" >> $pass_fail_result_file
echo "Kernel: $kernel_id" >> $pass_fail_result_file
echo "Baseline file used: $baseline_file" >> $pass_fail_result_file
echo "" >> $pass_fail_result_file
echo "Beaker Job: https://beaker.engineering.redhat.com/jobs/$job_id" >> $pass_fail_result_file
echo "Perf Results: $html_result_file" >> $pass_fail_result_file
echo "Whiteboard: $whiteboard" >> $pass_fail_result_file
echo "" >> $pass_fail_result_file
echo ""
cat $pass_fail_result_file
echo "Results from check_perf_ci.sh have been saved in $pass_fail_result_file."
echo ""

popd
set +x
