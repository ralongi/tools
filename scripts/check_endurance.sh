#!/bin/bash
dbg_flag=${dbg_flag:-"set -x"}
$dbg_flag

job_id=$1
if [[ $# -lt 1 ]]; then
	echo "Usage: $0 <Job ID>"
	echo "Example: $0 6863212"
	exit 0
fi

log=$(bkr job-results J:$job_id --prettyxml | grep -A40 '"/kernel/networking/openvswitch/perf" role="CLIENTS"' | grep taskout.log | awk -F '"' '{print $2}')

html_result_file=$(bkr job-results J:$job_id --prettyxml | grep -A40 '"/kernel/networking/openvswitch/perf" role="CLIENTS"' | grep 'mlx5_100_cx6.html' | awk '{print $2}' | awk -F "=" '{print $2}' | sed 's/"//g')

log=${log=:-""}
pushd ~/temp
result_file=$(basename $log)
rm -f $result_file
rm -f pass_fail.txt
wget --quiet -O $result_file $log

frame64_threshold=5000000
frame576_threshold=5000000
frame1218_threshold=4000000
frame1500_threshold=4000000

frame64_result=$(grep -A8 'jq --arg sz 64 --arg fl 1024' $result_file | tail -n1 | awk -F "," '{print $2}' | awk -F "." '{print $1}')
frame576_result=$(grep -A8 'jq --arg sz 576 --arg fl 1024' $result_file | tail -n1 | awk -F "," '{print $2}' | awk -F "." '{print $1}')
frame1218_result=$(grep -A8 'jq --arg sz 1218 --arg fl 1024' $result_file | tail -n1 | awk -F "," '{print $2}' | awk -F "." '{print $1}')
frame1500_result=$(grep -A8 'jq --arg sz 1500 --arg fl 1024' $result_file | tail -n1 | awk -F "," '{print $2}' | awk -F "." '{print $1}')

echo "Test: ovs-dpdk-vhostuser-pvp-queue1-pmds4-vcpus3-size64-vIOMMU-yes-vlan0"
if [[ $frame64_result -ge $frame64_threshold ]]; then echo "Result: PASS (Threshold: $frame64_threshold, Result: $frame64_result" | tee -a pass_fail.txt; else echo "Result: FAIL (Threshold: $frame64_threshold, Result: $frame64_result" | tee -a pass_fail.txt; fi
echo ""

echo "Test: ovs-dpdk-vhostuser-pvp-queue1-pmds4-vcpus3-size576-vIOMMU-yes-vlan0"
if [[ $frame576_result -ge $frame576_threshold ]]; then echo "Result: PASS (Threshold: $frame576_threshold, Result: $frame576_result" | tee -a pass_fail.txt; else echo "Result: FAIL (Threshold: $frame576_threshold, Result: $frame576_result" | tee -a pass_fail.txt; fi
echo ""

echo "Test: ovs-dpdk-vhostuser-pvp-queue1-pmds4-vcpus3-size1218-vIOMMU-yes-vlan0"
if [[ $frame1218_result -ge $frame1218_threshold ]]; then echo "Result: PASS (Threshold: $frame1218_threshold, Result: $frame1218_result" | tee -a pass_fail.txt; else echo "Result: FAIL (Threshold: $frame1218_threshold, Result: $frame1218_result" | tee -a pass_fail.txt; fi
echo ""

echo "Test: ovs-dpdk-vhostuser-pvp-queue1-pmds4-vcpus3-size1500-vIOMMU-yes-vlan0"
if [[ $frame1500_result -ge $frame1500_threshold ]]; then echo "Result: PASS (Threshold: $frame1500_threshold, Result: $frame1500_result" | tee -a pass_fail.txt; else echo "Result: FAIL (Threshold: $frame1500_threshold, Result: $frame1500_result" | tee -a pass_fail.txt; fi
echo ""

if [[ $(grep -i fail pass_fail.txt) ]]; then
	echo "Overall Result: One or more tests FAILED"
else
	echo "Overall Result: All tests PASSED"
fi
echo ""

echo "Result file: $html_result_file"
echo ""

popd

