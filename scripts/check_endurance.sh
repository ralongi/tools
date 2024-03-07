#!/bin/bash
$dbg_flag

job_id=$1
card_type=$2
if [[ $# -lt 2 ]]; then
	echo "Usage: $0 <Job ID> <Card Type>"
	echo "Example: $0 6863212 cx6"
	exit 0
fi

baseline_file=${baseline_file:-""}
card_type=$(echo "$card_type" | awk '{print toupper($0)}')

calc_pass_fail()
{
	$dbg_flag
	result=$1
	baseline=$2
	pf_pct_baseline=${pf_pct_baseline:-"-10"}
	delta=$(($result - $baseline))
	pct=$(awk "BEGIN { pc=100*${delta}/${baseline}; i=int(pc); print (pc-i<0.5)?i:i+1 }")
	if [[ $pct -gt 0 ]]; then pct="+"$pct; fi	
	if [[ $pct -ge $pf_pct_baseline ]]; then echo "Result: PASS baseline: $baseline, Result: $result" | tee -a $pass_fail_result_file; else echo "Result: FAIL baseline: $baseline, Result: $result" | tee -a $pass_fail_result_file; fi
	echo "Difference between actual result and baseline: $delta ($pct%)" | tee -a $pass_fail_result_file
}

get_result()
{
	$dbg_flag
	test=$1
	grep -A8 "jq --arg sz $frame_size --arg fl 1024" $result_file | tail -n1 | awk -F "," '{print $2}' | awk -F "." '{print $1}'
}

pushd ~
log=$(bkr job-results J:$job_id --prettyxml | grep -A40 '"/kernel/networking/openvswitch/perf" role="CLIENTS"' | grep taskout.log | awk -F '"' '{print $2}')
html_result_file=$(bkr job-results J:$job_id --prettyxml | grep -A40 '"/kernel/networking/openvswitch/perf" role="CLIENTS"' | grep html | awk '{print $2}' | awk -F "=" '{print $2}' | sed 's/"//g')
#pass_fail_result_file=$(mktemp)
pass_fail_result_file=pass_fail_results.txt
result_file=$(basename $log)
rm -f $html_result_file $result_file $pass_fail_result_file
wget --quiet -O $result_file $log

test1=ovs_dpdk_vhostuser_pvp_queue1_pmds4_vcpus3_size64_vIOMMU_yes_vlan0
test2=ovs_dpdk_vhostuser_pvp_queue1_pmds4_vcpus3_size576_vIOMMU_yes_vlan0
test3=ovs_dpdk_vhostuser_pvp_queue1_pmds4_vcpus3_size1218_vIOMMU_yes_vlan0
test4=ovs_dpdk_vhostuser_pvp_queue1_pmds4_vcpus3_size1500_vIOMMU_yes_vlan0

# Baseline values

if [[ $card_type == "CX5" ]]; then
	frame64_baseline=4604944
	frame576_baseline=4313267
	frame1218_baseline=3051383
	frame1500_baseline=2687603
elif [[ $card_type == "CX6" ]]; then
	frame64_baseline=4634026
	frame576_baseline=5165289
	frame1218_baseline=3857899
	frame1500_baseline=3451195
fi

# Report Results

echo "Reporting results for job https://beaker.engineering.redhat.com/jobs/$job_id for card type $card_type..." | tee -a $pass_fail_result_file
echo "" | tee -a $pass_fail_result_file

frame_size=64
frame64_result=$(get_result $test1)
if [[ $frame64_result ]]; then
	echo "" | tee -a $pass_fail_result_file
	echo "Test: $test1 (Frame size: $frame_size)" | tee -a $pass_fail_result_file
	calc_pass_fail $frame64_result $frame64_baseline
fi

frame_size=576
frame576_result=$(get_result $test2)
if [[ $frame576_result ]]; then
	echo "" | tee -a $pass_fail_result_file
	echo "Test: $test2 (Frame size: $frame_size)" | tee -a $pass_fail_result_file
	calc_pass_fail $frame576_result $frame576_baseline
fi

frame_size=1218
frame1218_result=$(get_result $test3)
if [[ $frame1218_result ]]; then
	echo "" | tee -a $pass_fail_result_file
	echo "Test: $test3 (Frame size: $frame_size)" | tee -a $pass_fail_result_file
	calc_pass_fail $frame1218_result $frame1218_baseline
fi

frame_size=1500
frame1500_result=$(get_result $test4)
if [[ $frame1500_result ]]; then
	echo "" | tee -a $pass_fail_result_file
	echo "Test: $test4 (Frame size: $frame_size)" | tee -a $pass_fail_result_file
	calc_pass_fail $frame1500_result $frame1500_baseline
fi

total_tests=$(grep 'Result:' $pass_fail_result_file | wc -l)
total_failed_tests=$(grep 'Result: FAIL' $pass_fail_result_file | wc -l)

echo "" | tee -a $pass_fail_result_file
if [[ $(grep -i fail $pass_fail_result_file) ]]; then	
	echo "Overall Result: $total_failed_tests of $total_tests tests FAILED"
	echo "" | tee -a $pass_fail_result_file
	echo "FAILED tests:"
	echo "" | tee -a $pass_fail_result_file	
	grep -B1 -A1 'Result: FAIL' $pass_fail_result_file
else
	echo "Overall Result: All $total_tests tests PASSED"
fi

if [[ $(grep -i fail $pass_fail_result_file) ]]; then
	echo "" | tee -a $pass_fail_result_file	
	echo "Overall Result: $total_failed_tests of $total_tests tests FAILED"	
fi

echo "" | tee -a $pass_fail_result_file
echo "Beaker Job: https://beaker.engineering.redhat.com/jobs/$job_id"
echo "Results: $html_result_file"
echo "" | tee -a $pass_fail_result_file

popd

#rm -f $html_result_file $result_file $pass_fail_result_file

popd
