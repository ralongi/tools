#!/bin/bash

$dbg_flag

job_id=$1
card_type=$2
if [[ $# -lt 2 ]]; then
	echo "Usage: $0 <Job ID> <Card Type>"
	echo "Example: $0 6863212 cx6"
	exit 0
fi

threshold_file=${threshold_file:-""}
card_type=$(echo "$card_type" | awk '{print toupper($0)}')
if [[ $card_type == "CX5" ]]; then
	threshold_file= ~/github/tools/scripts/cx5_perf_ci_threshold.txt
elif [[ $card_type == "CX6" ]]; then
	threshold_file=~/github/tools/scripts/cx6_perf_ci_threshold.txt
fi

source $threshold_file

test1=ovs_dpdk_vhostuser_pvp_queues1_pmds2_vcpus3_vIOMMU_no_vlan11
test2=ovs_dpdk_vhostuser_pvp_queues1_pmds4_vcpus3_vIOMMU_no_vlan11
test3=ovs_dpdk_vhostuser_pvp_queues2_pmds4_vcpus5_vIOMMU_no_vlan11
test4=ovs_dpdk_vhostuser_pvp_queues4_pmds8_vcpus9_vIOMMU_no_vlan11
test5=ovs_dpdk_vhostuser_pvp_queues1_pmds2_vcpus3_vIOMMU_yes_vlan0
test6=ovs_dpdk_vhostuser_pvp_queues1_pmds4_vcpus3_vIOMMU_yes_vlan0
test7=ovs_dpdk_vhostuser_pvp_queues2_pmds4_vcpus5_vIOMMU_yes_vlan0
test8=ovs_dpdk_vhostuser_pvp_queues4_pmds8_vcpus9_vIOMMU_yes_vlan0
test9=sriov_pvp_queues1_vcpus3_vIOMMU_yes_vlan0
test10=testpmd_as_switch_queues1_vIOMMU_no_vlan0
test11=ovs_kernel_pvp_queues1_vcpus3_vIOMMU_no_vlan0

calc_pass_fail()
{
	$dbg_flag
	result=$1
	threshold=$2
	pf_pct_threshold=${pf_pct_threshold:-"-10"}
	delta=$(($result - $threshold))
	pct=$(awk "BEGIN { pc=100*${delta}/${threshold}; i=int(pc); print (pc-i<0.5)?i:i+1 }")
	if [[ $pct -gt 0 ]]; then pct="+"$pct; fi	
	if [[ $pct -ge $pf_pct_threshold ]]; then echo "Result: PASS Threshold: $threshold, Result: $result" | tee -a $pass_fail_result_file; else echo "Result: FAIL Threshold: $threshold, Result: $result" | tee -a $pass_fail_result_file; fi
	echo "Difference between actual result and threshold: $delta ($pct%)" | tee -a $pass_fail_result_file
}

get_result()
{
	$dbg_flag
	test=$1
	grep -A8 "jq --arg sz $frame_size --arg fl $flows" $result_file | grep "$test" | awk -F "$test" '{print $2}' | awk -F '.' '{print $1}' | tr -d '",'
}

log=$(bkr job-results J:$job_id --prettyxml | grep -A40 '"/kernel/networking/openvswitch/perf" role="CLIENTS"' | grep taskout.log | awk -F '"' '{print $2}')

html_result_file=$(bkr job-results J:$job_id --prettyxml | grep -A40 '"/kernel/networking/openvswitch/perf" role="CLIENTS"' | grep html | awk '{print $2}' | awk -F "=" '{print $2}' | sed 's/"//g')

log=${log=:-""}
pass_fail_result_file=~/temp/pass_fail.txt
pushd ~/temp
result_file=$(basename $log)
rm -f $result_file
rm -f $pass_fail_result_file
wget --quiet -O $result_file $log

# frame size=64, flows=1024, loss-rate=0
frame_size=64
flows=1024
loss_rate=0

# ovs_dpdk_vhostuser_pvp vIOMMU=no vlan=11
fr64_fl1024_123_vno_vlan11_result=$(get_result $test1)
fr64_fl1024_143_vno_vlan11_result=$(get_result $test2)
fr64_fl1024_245_vno_vlan11_result=$(get_result $test3)
fr64_fl1024_489_vno_vlan11_result=$(get_result $test4)

# ovs_dpdk_vhostuser_pvp vIOMMU=yes vlan=0
fr64_fl1024_123_vyes_vlan0_result=$(get_result $test5)
fr64_fl1024_143_vyes_vlan0_result=$(get_result $test6)
fr64_fl1024_245_vyes_vlan0_result=$(get_result $test7)
fr64_fl1024_489_vyes_vlan0_result=$(get_result $test8)

# sriov_pvp
fr64_fl1024_sriov_13_vyes_vlan0_result=$(get_result $test9)

# testpmd as switch
fr64_fl1024_testpmd_vno_vlan0_result=$(get_result $test10)

# Report Results

echo "Reporting results for job https://beaker.engineering.redhat.com/jobs/$job_id for card type $card_type..." | tee -a $pass_fail_result_file
echo "" | tee -a $pass_fail_result_file

if [[ $fr64_fl1024_123_vno_vlan11_result ]]; then
	echo "" | tee -a $pass_fail_result_file
	echo "Test: $test1 (Frame size: $frame_size)" | tee -a $pass_fail_result_file
	calc_pass_fail $fr64_fl1024_123_vno_vlan11_result $fr64_fl1024_123_vno_vlan11_threshold
fi

if [[ $fr64_fl1024_143_vno_vlan11_result ]]; then
	echo "" | tee -a $pass_fail_result_file
	echo "Test: $test2 (Frame size: $frame_size)" | tee -a $pass_fail_result_file
	calc_pass_fail $fr64_fl1024_143_vno_vlan11_result $fr64_fl1024_143_vno_vlan11_threshold
fi

if [[ $fr64_fl1024_245_vno_vlan11_result ]]; then
	echo "" | tee -a $pass_fail_result_file
	echo "Test: $test3 (Frame size: $frame_size)" | tee -a $pass_fail_result_file
	calc_pass_fail $fr64_fl1024_245_vno_vlan11_result $fr64_fl1024_245_vno_vlan11_threshold
fi

if [[ $fr64_fl1024_489_vno_vlan11_result ]]; then
	echo "" | tee -a $pass_fail_result_file
	echo "Test: $test4 (Frame size: $frame_size)" | tee -a $pass_fail_result_file
	calc_pass_fail $fr64_fl1024_489_vno_vlan11_result $fr64_fl1024_489_vno_vlan11_threshold
fi

if [[ $fr64_fl1024_123_vyes_vlan0_result ]]; then
	echo "" | tee -a $pass_fail_result_file
	echo "Test: $test5 (Frame size: $frame_size)" | tee -a $pass_fail_result_file
	calc_pass_fail $fr64_fl1024_123_vyes_vlan0_result $fr64_fl1024_123_vyes_vlan0_threshold
fi

if [[ $fr64_fl1024_143_vyes_vlan0_result ]]; then
	echo "" | tee -a $pass_fail_result_file
	echo "Test: $test6 (Frame size: $frame_size)" | tee -a $pass_fail_result_file
	calc_pass_fail $fr64_fl1024_143_vyes_vlan0_result $fr64_fl1024_143_vyes_vlan0_threshold
fi

if [[ $fr64_fl1024_245_vyes_vlan0_result ]]; then
	echo "" | tee -a $pass_fail_result_file
	echo "Test: $test7 (Frame size: $frame_size)" | tee -a $pass_fail_result_file
	calc_pass_fail $fr64_fl1024_245_vyes_vlan0_result $fr64_fl1024_245_vyes_vlan0_threshold
fi

if [[ $fr64_fl1024_489_vyes_vlan0_result ]]; then
	echo "" | tee -a $pass_fail_result_file
	echo "Test: $test8 (Frame size: $frame_size)" | tee -a $pass_fail_result_file
	calc_pass_fail $fr64_fl1024_489_vyes_vlan0_result $fr64_fl1024_489_vyes_vlan0_threshold
fi

if [[ $fr64_fl1024_sriov_13_vyes_vlan0_result ]]; then
	echo "" | tee -a $pass_fail_result_file
	echo "Test: $test9 (Frame size: $frame_size)" | tee -a $pass_fail_result_file
	calc_pass_fail $fr64_fl1024_sriov_13_vyes_vlan0_result $fr64_fl1024_sriov_13_vyes_vlan0_threshold
fi

if [[ $fr64_fl1024_testpmd_vno_vlan0_result ]]; then
	echo "" | tee -a $pass_fail_result_file
	echo "Test: $test10 (Frame size: $frame_size)" | tee -a $pass_fail_result_file
	calc_pass_fail $fr64_fl1024_testpmd_vno_vlan0_result $fr64_fl1024_testpmd_vno_vlan0_threshold
fi

# frame size=64, flows=1024 ovs_kernel, loss-rate=0.002
frame_size=64
flows=1024
loss_rate=0.002

# ovs_kernel_pvp
fr64_fl1024_kernel_13_vno_vlan0_result=$(get_result $test11)

if [[ $fr64_fl1024_kernel_13_vno_vlan0_result ]]; then
	echo "" | tee -a $pass_fail_result_file
	echo "Test: $test11 (Frame size: $frame_size)" | tee -a $pass_fail_result_file
	calc_pass_fail $fr64_fl1024_kernel_13_vno_vlan0_result $fr64_fl1024_kernel_13_vno_vlan0_threshold
fi

# frame size=128, flows=1024, loss-rate=0
frame_size=128
flows=1024
loss_rate=0

# ovs_dpdk_vhostuser_pvp vIOMMU=no vlan=11 frame=128
fr128_fl1024_123_vno_vlan11_result=$(get_result $test1)
fr128_fl1024_143_vno_vlan11_result=$(get_result $test2)
fr128_fl1024_245_vno_vlan11_result=$(get_result $test3)
fr128_fl1024_489_vno_vlan11_result=$(get_result $test4)

# ovs_dpdk_vhostuser_pvp vIOMMU=yes vlan=0 frame=128
fr128_fl1024_123_vyes_vlan0_result=$(get_result $test5)
fr128_fl1024_143_vyes_vlan0_result=$(get_result $test6)
fr128_fl1024_245_vyes_vlan0_result=$(get_result $test7)
fr128_fl1024_489_vyes_vlan0_result=$(get_result $test8)

if [[ $fr128_fl1024_123_vno_vlan11_result ]]; then
	echo "" | tee -a $pass_fail_result_file
	echo "Test: $test1 (Frame size: $frame_size)" | tee -a $pass_fail_result_file
	calc_pass_fail $fr128_fl1024_123_vno_vlan11_result $fr128_fl1024_123_vno_vlan11_threshold
fi

if [[ $fr128_fl1024_143_vno_vlan11_result ]]; then
	echo "" | tee -a $pass_fail_result_file
	echo "Test: $test2 (Frame size: $frame_size)" | tee -a $pass_fail_result_file
	calc_pass_fail $fr128_fl1024_143_vno_vlan11_result $fr128_fl1024_143_vno_vlan11_threshold
fi

if [[ $fr128_fl1024_245_vno_vlan11_result ]]; then
	echo "" | tee -a $pass_fail_result_file
	echo "Test: $test3 (Frame size: $frame_size)" | tee -a $pass_fail_result_file
	calc_pass_fail $fr128_fl1024_245_vno_vlan11_result $fr128_fl1024_245_vno_vlan11_threshold
fi

if [[ $fr128_fl1024_489_vno_vlan11_result ]]; then
	echo "" | tee -a $pass_fail_result_file
	echo "Test: $test4 (Frame size: $frame_size)" | tee -a $pass_fail_result_file
	calc_pass_fail $fr128_fl1024_489_vno_vlan11_result $fr128_fl1024_489_vno_vlan11_threshold
fi

if [[ $fr128_fl1024_123_vyes_vlan0_result ]]; then
	echo "" | tee -a $pass_fail_result_file
	echo "Test: $test5 (Frame size: $frame_size)" | tee -a $pass_fail_result_file
	calc_pass_fail $fr128_fl1024_123_vyes_vlan0_result $fr128_fl1024_123_vyes_vlan0_threshold
fi

if [[ $fr128_fl1024_143_vyes_vlan0_result ]]; then
	echo "" | tee -a $pass_fail_result_file
	echo "Test: $test6 (Frame size: $frame_size)" | tee -a $pass_fail_result_file
	calc_pass_fail $fr128_fl1024_143_vyes_vlan0_result $fr128_fl1024_143_vyes_vlan0_threshold
fi

if [[ $fr128_fl1024_245_vyes_vlan0_result ]]; then
	echo "" | tee -a $pass_fail_result_file
	echo "Test: $test7 (Frame size: $frame_size)" | tee -a $pass_fail_result_file
	calc_pass_fail $fr128_fl1024_245_vyes_vlan0_result $fr128_fl1024_245_vyes_vlan0_threshold
fi

if [[ $fr128_fl1024_489_vyes_vlan0_result ]]; then
	echo "" | tee -a $pass_fail_result_file
	echo "Test: $test8 (Frame size: $frame_size)" | tee -a $pass_fail_result_file
	calc_pass_fail $fr128_fl1024_489_vyes_vlan0_result $fr128_fl1024_489_vyes_vlan0_threshold
fi

# frame size=256, flows=1024, loss-rate=0
frame_size=256
flows=1024
loss_rate=0

# ovs_dpdk_vhostuser_pvp vIOMMU=no vlan=11 frame=256
fr256_fl1024_123_vno_vlan11_result=$(get_result $test1)
fr256_fl1024_143_vno_vlan11_result=$(get_result $test2)
fr256_fl1024_245_vno_vlan11_result=$(get_result $test3)
fr256_fl1024_489_vno_vlan11_result=$(get_result $test4)

# ovs_dpdk_vhostuser_pvp vIOMMU=yes vlan=0 frame=256 
fr256_fl1024_123_vyes_vlan0_result=$(get_result $test5)
fr256_fl1024_143_vyes_vlan0_result=$(get_result $test6)
fr256_fl1024_245_vyes_vlan0_result=$(get_result $test7)
fr256_fl1024_489_vyes_vlan0_result=$(get_result $test8)

if [[ $fr256_fl1024_123_vno_vlan11_result ]]; then
	echo "" | tee -a $pass_fail_result_file
	echo "Test: $test1 (Frame size: $frame_size)" | tee -a $pass_fail_result_file
	calc_pass_fail $fr256_fl1024_123_vno_vlan11_result $fr256_fl1024_123_vno_vlan11_threshold
fi

if [[ $fr256_fl1024_143_vno_vlan11_result ]]; then
	echo "" | tee -a $pass_fail_result_file
	echo "Test: $test2 (Frame size: $frame_size)" | tee -a $pass_fail_result_file
	calc_pass_fail $fr256_fl1024_143_vno_vlan11_result $fr256_fl1024_143_vno_vlan11_threshold
fi

if [[ $fr256_fl1024_245_vno_vlan11_result ]]; then
	echo "" | tee -a $pass_fail_result_file
	echo "Test: $test3 (Frame size: $frame_size)" | tee -a $pass_fail_result_file
	calc_pass_fail $fr256_fl1024_245_vno_vlan11_result $fr256_fl1024_245_vno_vlan11_threshold
fi

if [[ $fr256_fl1024_489_vno_vlan11_result ]]; then
	echo "" | tee -a $pass_fail_result_file
	echo "Test: $test4 (Frame size: $frame_size)" | tee -a $pass_fail_result_file
	calc_pass_fail $fr256_fl1024_489_vno_vlan11_result $fr256_fl1024_489_vno_vlan11_threshold
fi

if [[ $fr256_fl1024_123_vyes_vlan0_result ]]; then
	echo "" | tee -a $pass_fail_result_file
	echo "Test: $test5 (Frame size: $frame_size)" | tee -a $pass_fail_result_file
	calc_pass_fail $fr256_fl1024_123_vyes_vlan0_result $fr256_fl1024_123_vyes_vlan0_threshold
fi

if [[ $fr256_fl1024_143_vyes_vlan0_result ]]; then
	echo "" | tee -a $pass_fail_result_file
	echo "Test: $test6 (Frame size: $frame_size)" | tee -a $pass_fail_result_file
	calc_pass_fail $fr256_fl1024_143_vyes_vlan0_result $fr256_fl1024_143_vyes_vlan0_threshold
fi

if [[ $fr256_fl1024_245_vyes_vlan0_result ]]; then
	echo "" | tee -a $pass_fail_result_file
	echo "Test: $test7 (Frame size: $frame_size)" | tee -a $pass_fail_result_file
	calc_pass_fail $fr256_fl1024_245_vyes_vlan0_result $fr256_fl1024_245_vyes_vlan0_threshold
fi

if [[ $fr256_fl1024_489_vyes_vlan0_result ]]; then
	echo "" | tee -a $pass_fail_result_file
	echo "Test: $test8 (Frame size: $frame_size)" | tee -a $pass_fail_result_file
	calc_pass_fail $fr256_fl1024_489_vyes_vlan0_result $fr256_fl1024_489_vyes_vlan0_threshold
fi

# frame size=1500, flows=1024, loss-rate=0
frame_size=1500
flows=1024
loss_rate=0

# ovs_dpdk_vhostuser_pvp vIOMMU=no vlan=11 frame=1500
fr1500_fl1024_123_vno_vlan11_result=$(get_result $test1)
fr1500_fl1024_143_vno_vlan11_result=$(get_result $test2)
fr1500_fl1024_245_vno_vlan11_result=$(get_result $test3)
fr1500_fl1024_489_vno_vlan11_result=$(get_result $test4)

# ovs_dpdk_vhostuser_pvp vIOMMU=yes vlan=0 frame=1500
fr1500_fl1024_123_vyes_vlan0_result=$(get_result $test5)
fr1500_fl1024_143_vyes_vlan0_result=$(get_result $test6)
fr1500_fl1024_245_vyes_vlan0_result=$(get_result $test7)
fr1500_fl1024_489_vyes_vlan0_result=$(get_result $test8)

if [[ $fr1500_fl1024_123_vno_vlan11_result ]]; then
	echo "" | tee -a $pass_fail_result_file
	echo "Test: $test1 (Frame size: $frame_size)" | tee -a $pass_fail_result_file
	calc_pass_fail $fr1500_fl1024_123_vyes_vlan0_result $fr1500_fl1024_123_vyes_vlan0_threshold
fi

if [[ $fr1500_fl1024_143_vno_vlan11_result ]]; then
	echo "" | tee -a $pass_fail_result_file
	echo "Test: $test2 (Frame size: $frame_size)" | tee -a $pass_fail_result_file
	calc_pass_fail $fr1500_fl1024_143_vno_vlan11_result $fr1500_fl1024_143_vno_vlan11_threshold
fi

if [[ $fr1500_fl1024_245_vno_vlan11_result ]]; then
	echo "" | tee -a $pass_fail_result_file
	echo "Test: $test3 (Frame size: $frame_size)" | tee -a $pass_fail_result_file
	calc_pass_fail $fr1500_fl1024_245_vno_vlan11_result $fr1500_fl1024_245_vno_vlan11_threshold
fi

if [[ $fr1500_fl1024_489_vno_vlan11_result ]]; then
	echo "" | tee -a $pass_fail_result_file
	echo "Test: $test4 (Frame size: $frame_size)" | tee -a $pass_fail_result_file
	calc_pass_fail $fr1500_fl1024_489_vno_vlan11_result $fr1500_fl1024_489_vno_vlan11_threshold
fi

if [[ $fr1500_fl1024_123_vyes_vlan0_result ]]; then
	echo "" | tee -a $pass_fail_result_file
	echo "Test: $test5 (Frame size: $frame_size)" | tee -a $pass_fail_result_file
	calc_pass_fail $fr1500_fl1024_123_vyes_vlan0_result $fr1500_fl1024_123_vyes_vlan0_threshold
fi

if [[ $fr1500_fl1024_143_vyes_vlan0_result ]]; then
	echo "" | tee -a $pass_fail_result_file
	echo "Test: $test6 (Frame size: $frame_size)" | tee -a $pass_fail_result_file
	calc_pass_fail $fr1500_fl1024_143_vyes_vlan0_result $fr1500_fl1024_143_vyes_vlan0_threshold
fi

if [[ $fr1500_fl1024_245_vyes_vlan0_result ]]; then
	echo "" | tee -a $pass_fail_result_file
	echo "Test: $test7 (Frame size: $frame_size)" | tee -a $pass_fail_result_file
	calc_pass_fail $fr1500_fl1024_245_vyes_vlan0_result $fr1500_fl1024_245_vyes_vlan0_threshold
fi

if [[ $fr1500_fl1024_489_vyes_vlan0_result ]]; then
	echo "" | tee -a $pass_fail_result_file
	echo "Test: $test8 (Frame size: $frame_size)" | tee -a $pass_fail_result_file
	calc_pass_fail $fr1500_fl1024_489_vyes_vlan0_result $fr1500_fl1024_489_vyes_vlan0_threshold
fi

# sriov_pvp
# Frame=1500
frame_size=1500
flows=1024
loss_rate=0

fr1500_fl1024_sriov_13_vyes_vlan0_result=$(get_result $test9)

if [[ $fr1500_fl1024_sriov_13_vyes_vlan0_result ]]; then
	echo "" | tee -a $pass_fail_result_file
	echo "Test: $test9 (Frame size: $frame_size)" | tee -a $pass_fail_result_file
	calc_pass_fail $fr1500_fl1024_sriov_13_vyes_vlan0_result $fr1500_fl1024_sriov_13_vyes_vlan0_threshold
fi

# frame size=2000, flows=1024, loss-rate=0
frame_size=2000
flows=1024
loss_rate=0

# ovs_dpdk_vhostuser_pvp vIOMMU=no vlan=11 frame=2000
fr2000_fl1024_123_vno_vlan11_result=$(get_result $test1)
fr2000_fl1024_143_vno_vlan11_result=$(get_result $test2)

# ovs_dpdk_vhostuser_pvp vIOMMU=yes vlan=0 frame=2000
fr2000_fl1024_123_vyes_vlan0_result=$(get_result $test5)
fr2000_fl1024_143_vyes_vlan0_result=$(get_result $test6)

if [[ $fr2000_fl1024_123_vno_vlan11_result ]]; then
	echo "" | tee -a $pass_fail_result_file
	echo "Test: $test1 (Frame size: $frame_size)" | tee -a $pass_fail_result_file
	calc_pass_fail $fr2000_fl1024_123_vno_vlan11_result $fr2000_fl1024_123_vno_vlan11_threshold
fi

if [[ $fr2000_fl1024_143_vno_vlan11_result ]]; then
	echo "" | tee -a $pass_fail_result_file
	echo "Test: $test2 (Frame size: $frame_size)" | tee -a $pass_fail_result_file
	calc_pass_fail $fr2000_fl1024_143_vno_vlan11_result $fr2000_fl1024_143_vno_vlan11_threshold
fi

if [[ $fr2000_fl1024_123_vyes_vlan0_result ]]; then
	echo "" | tee -a $pass_fail_result_file
	echo "Test: $test5 (Frame size: $frame_size)" | tee -a $pass_fail_result_file
	calc_pass_fail $fr2000_fl1024_123_vyes_vlan0_result $fr2000_fl1024_123_vyes_vlan0_threshold
fi

if [[ $fr2000_fl1024_143_vyes_vlan0_result ]]; then
	echo "" | tee -a $pass_fail_result_file
	echo "Test: $test6 (Frame size: $frame_size)" | tee -a $pass_fail_result_file
	calc_pass_fail $fr2000_fl1024_143_vyes_vlan0_result $fr2000_fl1024_143_vyes_vlan0_threshold
fi

# frame size=9200, flows=1024, loss-rate=0
frame_size=9200
flows=1024
loss_rate=0

# ovs_dpdk_vhostuser_pvp vIOMMU=no vlan=11 frame=9200
fr9200_fl1024_123_vno_vlan11_result=$(get_result $test1)
fr9200_fl1024_143_vno_vlan11_result=$(get_result $test2)

# ovs_dpdk_vhostuser_pvp vIOMMU=yes vlan=0 frame=9200
fr9200_fl1024_123_vyes_vlan0_result=$(get_result $test5)
fr9200_fl1024_143_vyes_vlan0_result=$(get_result $test6)

if [[ $fr9200_fl1024_123_vno_vlan11_result ]]; then
	echo "" | tee -a $pass_fail_result_file
	echo "Test: $test1 (Frame size: $frame_size)" | tee -a $pass_fail_result_file
	calc_pass_fail $fr9200_fl1024_123_vno_vlan11_result $fr9200_fl1024_123_vno_vlan11_threshold
fi

if [[ $fr9200_fl1024_143_vno_vlan11_result ]]; then
	echo "" | tee -a $pass_fail_result_file
	echo "Test: $test2 (Frame size: $frame_size)" | tee -a $pass_fail_result_file
	calc_pass_fail $fr9200_fl1024_143_vno_vlan11_result $fr9200_fl1024_143_vno_vlan11_threshold
fi

if [[ $fr9200_fl1024_123_vyes_vlan0_result ]]; then
	echo "" | tee -a $pass_fail_result_file
	echo "Test: $test5 (Frame size: $frame_size)" | tee -a $pass_fail_result_file
	calc_pass_fail $fr9200_fl1024_123_vyes_vlan0_result $fr9200_fl1024_123_vyes_vlan0_threshold
fi

if [[ $fr9200_fl1024_143_vyes_vlan0_result ]]; then
	echo "" | tee -a $pass_fail_result_file
	echo "Test: $test6 (Frame size: $frame_size)" | tee -a $pass_fail_result_file
	calc_pass_fail $fr9200_fl1024_143_vyes_vlan0_result $fr9200_fl1024_143_vyes_vlan0_threshold
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
