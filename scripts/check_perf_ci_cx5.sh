#!/bin/bash

$dbg_flag

job_id=$1
if [[ $# -lt 1 ]]; then
	echo "Usage: $0 <Job ID>"
	echo "Example: $0 6863212"
	exit 0
fi

get_delta_values()
{
	$dbg_flag
	result=$1
	threshold=$2
	delta=$(($result - $threshold))
	pct=$(awk "BEGIN { pc=100*${delta}/${threshold}; i=int(pc); print (pc-i<0.5)?i:i+1 }")
}

log=$(bkr job-results J:$job_id --prettyxml | grep -A40 '"/kernel/networking/openvswitch/perf" role="CLIENTS"' | grep taskout.log | awk -F '"' '{print $2}')

html_result_file=$(bkr job-results J:$job_id --prettyxml | grep -A40 '"/kernel/networking/openvswitch/perf" role="CLIENTS"' | grep 'mlx5_100_cx6.html' | awk '{print $2}' | awk -F "=" '{print $2}' | sed 's/"//g')

log=${log=:-""}
pushd ~/temp
result_file=$(basename $log)
rm -f $result_file
rm -f pass_fail.txt
wget --quiet -O $result_file $log

# frame size=64, flows=1024, loss-rate=0
frame_size=64
flows=1024
loss_rate=0

fr64_fl1024_123_vno_vlan11_threshold=2943507
fr64_fl1024_143_vno_vlan11_threshold=5990018
fr64_fl1024_245_vno_vlan11_threshold=5883166
fr64_fl1024_489_vno_vlan11_threshold=11567980
fr64_fl1024_123_vyes_vlan0_threshold=2756997
fr64_fl1024_143_vyes_vlan0_threshold=6363430
fr64_fl1024_245_vyes_vlan0_threshold=6449406
fr64_fl1024_489_vyes_vlan0_threshold=10910681
fr64_fl1024_sriov_13_vyes_vlan0_threshold=34255389
fr64_fl1024_testpmd_vno_vlan0_threshold=6247242

# ovs_dpdk_vhostuser_pvp vIOMMU=no vlan=11

fr64_fl1024_123_vno_vlan11_testname=$(grep -A8 'jq --arg sz 64 --arg fl 1024' $result_file | grep 'result=' | grep vlan11 | awk -F "," '{print $1}' | awk -F '"' '{print $2}')
fr64_fl1024_123_vno_vlan11_result=$(grep -A8 'jq --arg sz 64 --arg fl 1024' $result_file | grep 'result=' | grep vlan11 | awk -F "," '{print $2}' | awk -F "." '{print $1}')

fr64_fl1024_143_vno_vlan11_testname=$(grep -A8 'jq --arg sz 64 --arg fl 1024' $result_file | grep 'result=' | grep vlan11 | awk -F "," '{print $3}' | awk -F '"' '{print $2}')
fr64_fl1024_143_vno_vlan11_result=$(grep -A8 'jq --arg sz 64 --arg fl 1024' $result_file | grep 'result=' | grep vlan11 | awk -F "," '{print $4}' | awk -F "." '{print $1}')

fr64_fl1024_245_vno_vlan11_testname=$(grep -A8 'jq --arg sz 64 --arg fl 1024' $result_file | grep 'result=' | grep vlan11 | awk -F "," '{print $5}' | awk -F '"' '{print $2}')
fr64_fl1024_245_vno_vlan11_result=$(grep -A8 'jq --arg sz 64 --arg fl 1024' $result_file | grep 'result=' | grep vlan11 | awk -F "," '{print $6}' | awk -F "." '{print $1}')

r64_fl1024_489_vno_vlan11_testname=$(grep -A8 'jq --arg sz 64 --arg fl 1024' $result_file | grep 'result=' | grep vlan11 | awk -F "," '{print $7}' | awk -F '"' '{print $2}')
fr64_fl1024_489_vno_vlan11_result=$(grep -A8 'jq --arg sz 64 --arg fl 1024' $result_file | grep 'result=' | grep vlan11 | awk -F "," '{print $8}' | awk -F "." '{print $1}')


# ovs_dpdk_vhostuser_pvp vIOMMU=yes vlan=0

fr64_fl1024_123_vyes_vlan0_testname=$(grep -A8 'jq --arg sz 64 --arg fl 1024' $result_file | grep 'result=' | grep vlan0 | awk -F "," '{print $9}' | awk -F '"' '{print $2}')
fr64_fl1024_123_vyes_vlan0_result=$(grep -A8 'jq --arg sz 64 --arg fl 1024' $result_file | grep 'result=' | grep vlan0 | awk -F "," '{print $10}' | awk -F "." '{print $1}')

fr64_fl1024_143_vyes_vlan0_testname=$(grep -A8 'jq --arg sz 64 --arg fl 1024' $result_file | grep 'result=' | grep vlan0 | awk -F "," '{print $11}' | awk -F '"' '{print $2}')
fr64_fl1024_143_vyes_vlan0_result=$(grep -A8 'jq --arg sz 64 --arg fl 1024' $result_file | grep 'result=' | grep vlan0 | awk -F "," '{print $12}' | awk -F "." '{print $1}')

fr64_fl1024_245_vyes_vlan0_testname=$(grep -A8 'jq --arg sz 64 --arg fl 1024' $result_file | grep 'result=' | grep vlan0 | awk -F "," '{print $13}' | awk -F '"' '{print $2}')
fr64_fl1024_245_vyes_vlan0_result=$(grep -A8 'jq --arg sz 64 --arg fl 1024' $result_file | grep 'result=' | grep vlan0 | awk -F "," '{print $14}' | awk -F "." '{print $1}')

fr64_fl1024_489_vyes_vlan0_testname=$(grep -A8 'jq --arg sz 64 --arg fl 1024' $result_file | grep 'result=' | grep vlan0 | awk -F "," '{print $15}' | awk -F '"' '{print $2}')
fr64_fl1024_489_vyes_vlan0_result=$(grep -A8 'jq --arg sz 64 --arg fl 1024' $result_file | grep 'result=' | grep vlan0 | awk -F "," '{print $16}' | awk -F "." '{print $1}')

# sriov_pvp

fr64_fl1024_sriov_13_vyes_vlan0_testname=$(grep -A8 'jq --arg sz 64 --arg fl 1024' $result_file | grep 'result=' | grep vlan0 | awk -F "," '{print $17}' | awk -F '"' '{print $2}')
fr64_fl1024_sriov_13_vyes_vlan0_result=$(grep -A8 'jq --arg sz 64 --arg fl 1024' $result_file | grep 'result=' | grep vlan0 | awk -F "," '{print $18}' | awk -F "." '{print $1}')

# testpmd as switch

fr64_fl1024_testpmd_vno_vlan0_testname=$(grep -A8 'jq --arg sz 64 --arg fl 1024' $result_file | grep 'result=' | grep vlan0 | awk -F "," '{print $19}' | awk -F '"' '{print $2}')
fr64_fl1024_testpmd_vno_vlan0_result=$(grep -A8 'jq --arg sz 64 --arg fl 1024' $result_file | grep 'result=' | grep vlan0 | awk -F "," '{print $20}' | awk -F "." '{print $1}')

# Report Results

echo "" | tee -a pass_fail.txt
echo "Test: ovs_dpdk_vhostuser_pvp vIOMMU=no vlan=11 frame=64 queues=1 pmds=2 vcpus=3" | tee -a pass_fail.txt
get_delta_values $fr64_fl1024_123_vno_vlan11_result $fr64_fl1024_123_vno_vlan11_threshold
if [[ $fr64_fl1024_123_vno_vlan11_result -ge $fr64_fl1024_123_vno_vlan11_threshold ]]; then echo "Result: PASS Threshold: $fr64_fl1024_123_vno_vlan11_threshold, Result: $fr64_fl1024_123_vno_vlan11_result" | tee -a pass_fail.txt; else echo "Result: FAIL Threshold: $fr64_fl1024_123_vno_vlan11_threshold, Result: $fr64_fl1024_123_vno_vlan11_result" | tee -a pass_fail.txt; fi
echo "Difference between actual result and threshold: $delta ($pct%)" | tee -a pass_fail.txt

echo "" | tee -a pass_fail.txt
echo "Test: ovs_dpdk_vhostuser_pvp vIOMMU=no vlan=11 frame=64 queues=1 pmds=4 vcpus=3" | tee -a pass_fail.txt
get_delta_values $fr64_fl1024_143_vno_vlan11_result $fr64_fl1024_143_vno_vlan11_threshold
if [[ $fr64_fl1024_143_vno_vlan11_result -ge $fr64_fl1024_143_vno_vlan11_threshold ]]; then echo "Result: PASS Threshold: $fr64_fl1024_143_vno_vlan11_threshold, Result: $fr64_fl1024_143_vno_vlan11_result" | tee -a pass_fail.txt; else echo "Result: FAIL Threshold: $fr64_fl1024_143_vno_vlan11_threshold, Result: $fr64_fl1024_143_vno_vlan11_result" | tee -a pass_fail.txt; fi
echo "Difference between actual result and threshold: $delta ($pct%)" | tee -a pass_fail.txt

echo "" | tee -a pass_fail.txt
echo "Test: ovs_dpdk_vhostuser_pvp vIOMMU=no vlan=11 frame=64 queues=2 pmds=4 vcpus=5" | tee -a pass_fail.txt
get_delta_values $fr64_fl1024_245_vno_vlan11_result $fr64_fl1024_245_vno_vlan11_threshold
if [[ $fr64_fl1024_245_vno_vlan11_result -ge $fr64_fl1024_245_vno_vlan11_threshold ]]; then echo "Result: PASS Threshold: $fr64_fl1024_245_vno_vlan11_threshold, Result: $fr64_fl1024_245_vno_vlan11_result" | tee -a pass_fail.txt; else echo "Result: FAIL Threshold: $fr64_fl1024_245_vno_vlan11_threshold, Result: $fr64_fl1024_245_vno_vlan11_result" | tee -a pass_fail.txt; fi
echo "Difference between actual result and threshold: $delta ($pct%)" | tee -a pass_fail.txt

echo "" | tee -a pass_fail.txt
echo "Test: ovs_dpdk_vhostuser_pvp vIOMMU=no vlan=11 frame=64 queues=4 pmds=8 vcpus=9" | tee -a pass_fail.txt
get_delta_values $fr64_fl1024_489_vno_vlan11_result $fr64_fl1024_489_vno_vlan11_threshold
if [[ $fr64_fl1024_489_vno_vlan11_result -ge $fr64_fl1024_489_vno_vlan11_threshold ]]; then echo "Result: PASS Threshold: $fr64_fl1024_489_vno_vlan11_threshold, Result: $fr64_fl1024_489_vno_vlan11_result" | tee -a pass_fail.txt | tee -a pass_fail.txt; else echo "Result: FAIL Threshold: $fr64_fl1024_489_vno_vlan11_threshold, Result: $fr64_fl1024_489_vno_vlan11_result" | tee -a pass_fail.txt; fi
echo "Difference between actual result and threshold: $delta ($pct%)" | tee -a pass_fail.txt

echo "" | tee -a pass_fail.txt
echo "Test: ovs_dpdk_vhostuser_pvp vIOMMU=yes vlan=0 frame=64 queues=1 pmds=2 vcpus=3" | tee -a pass_fail.txt
get_delta_values $fr64_fl1024_123_vyes_vlan0_result $fr64_fl1024_123_vyes_vlan0_threshold
if [[ $fr64_fl1024_123_vyes_vlan0_result -ge $fr64_fl1024_123_vyes_vlan0_threshold ]]; then echo "Result: PASS Threshold: $fr64_fl1024_123_vyes_vlan0_threshold, Result: $fr64_fl1024_123_vyes_vlan0_result" | tee -a pass_fail.txt; else echo "Result: FAIL Threshold: $fr64_fl1024_123_vyes_vlan0_threshold, Result: $fr64_fl1024_123_vyes_vlan0_result" | tee -a pass_fail.txt; fi
echo "Difference between actual result and threshold: $delta ($pct%)" | tee -a pass_fail.txt

echo "" | tee -a pass_fail.txt
echo "Test: ovs_dpdk_vhostuser_pvp vIOMMU=yes vlan=0 frame=64 queues=1 pmds=4 vcpus=3" | tee -a pass_fail.txt
get_delta_values $fr64_fl1024_143_vyes_vlan0_result $fr64_fl1024_143_vyes_vlan0_threshold
if [[ $fr64_fl1024_143_vyes_vlan0_result -ge $fr64_fl1024_143_vyes_vlan0_threshold ]]; then echo "Result: PASS Threshold: $fr64_fl1024_143_vyes_vlan0_threshold, Result: $fr64_fl1024_143_vyes_vlan0_result" | tee -a pass_fail.txt; else echo "Result: FAIL Threshold: $fr64_fl1024_143_vyes_vlan0_threshold, Result: $fr64_fl1024_143_vyes_vlan0_result" | tee -a pass_fail.txt; fi
echo "Difference between actual result and threshold: $delta ($pct%)" | tee -a pass_fail.txt

echo "" | tee -a pass_fail.txt
echo "Test: ovs_dpdk_vhostuser_pvp vIOMMU=yes vlan=0 frame=64 queues=2 pmds=4 vcpus=5" | tee -a pass_fail.txt
get_delta_values $fr64_fl1024_245_vyes_vlan0_result $fr64_fl1024_245_vyes_vlan0_threshold
if [[ $fr64_fl1024_245_vyes_vlan0_result -ge $fr64_fl1024_245_vyes_vlan0_threshold ]]; then echo "Result: PASS Threshold: $fr64_fl1024_245_vyes_vlan0_threshold, Result: $fr64_fl1024_245_vyes_vlan0_result" | tee -a pass_fail.txt; else echo "Result: FAIL Threshold: $fr64_fl1024_245_vyes_vlan0_threshold, Result: $fr64_fl1024_245_vyes_vlan0_result" | tee -a pass_fail.txt; fi
echo "Difference between actual result and threshold: $delta ($pct%)" | tee -a pass_fail.txt

echo "" | tee -a pass_fail.txt
echo "Test: ovs_dpdk_vhostuser_pvp vIOMMU=yes vlan=0 frame=64 queues=4 pmds=8 vcpus=9" | tee -a pass_fail.txt
get_delta_values $fr64_fl1024_489_vyes_vlan0_result $fr64_fl1024_489_vyes_vlan0_threshold
if [[ $fr64_fl1024_489_vyes_vlan0_result -ge $fr64_fl1024_489_vyes_vlan0_threshold ]]; then echo "Result: PASS Threshold: $fr64_fl1024_489_vyes_vlan0_threshold, Result: $fr64_fl1024_489_vyes_vlan0_result" | tee -a pass_fail.txt; else echo "Result: FAIL Threshold: $fr64_fl1024_489_vyes_vlan0_threshold, Result: $fr64_fl1024_489_vyes_vlan0_result" | tee -a pass_fail.txt; fi
echo "Difference between actual result and threshold: $delta ($pct%)" | tee -a pass_fail.txt

echo "" | tee -a pass_fail.txt
echo "Test: sriov_pvp vIOMMU=yes vlan=0 frame=64 queues=1 vcpus=3" | tee -a pass_fail.txt
get_delta_values $fr64_fl1024_sriov_13_vyes_vlan0_result $fr64_fl1024_sriov_13_vyes_vlan0_threshold
if [[ $fr64_fl1024_sriov_13_vyes_vlan0_result -ge $fr64_fl1024_sriov_13_vyes_vlan0_threshold ]]; then echo "Result: PASS Threshold: $fr64_fl1024_sriov_13_vyes_vlan0_threshold, Result: $fr64_fl1024_sriov_13_vyes_vlan0_result" | tee -a pass_fail.txt; else echo "Result: FAIL Threshold: $fr64_fl1024_sriov_13_vyes_vlan0_threshold, Result: $fr64_fl1024_sriov_13_vyes_vlan0_result" | tee -a pass_fail.txt; fi
echo "Difference between actual result and threshold: $delta ($pct%)" | tee -a pass_fail.txt

echo "" | tee -a pass_fail.txt
echo "Test: testpmd_as_switch vIOMMU=no vlan=0 frame=64 queues=1" | tee -a pass_fail.txt
get_delta_values $fr64_fl1024_testpmd_vno_vlan0_result $fr64_fl1024_testpmd_vno_vlan0_threshold
if [[ $fr64_fl1024_testpmd_vno_vlan0_result -ge $fr64_fl1024_testpmd_vno_vlan0_threshold ]]; then echo "Result: PASS Threshold: $fr64_fl1024_testpmd_vno_vlan0_threshold, Result: $fr64_fl1024_testpmd_vno_vlan0_result" | tee -a pass_fail.txt; else echo "Result: FAIL Threshold: $fr64_fl1024_testpmd_vno_vlan0_threshold, Result: $fr64_fl1024_testpmd_vno_vlan0_result" | tee -a pass_fail.txt; fi
echo "Difference between actual result and threshold: $delta ($pct%)" | tee -a pass_fail.txt


# frame size=64, flows=1024 ovs_kernel, loss-rate=0.002
frame_size=64
flows=1024
loss_rate=0.002

# ovs_kernel_pvp
echo "Tests: ovs_kernel_pvp" | tee -a pass_fail.txt


fr64_fl1024_kernel_13_vno_vlan0_threshold=452413

fr64_fl1024_kernel_13_vno_vlan0_result=$(grep -A8 'jq --arg sz 64 --arg fl 1024' $result_file | grep 'result=' | grep vlan0 | awk -F "," '{print $2}' | awk -F "." '{print $1}' | tail -n1)

echo "" | tee -a pass_fail.txt
echo "Test: ovs_kernel_pvp vIOMMU=no vlan=0 frame=64 queues=1 vcpus=3" | tee -a pass_fail.txt
get_delta_values $fr64_fl1024_kernel_13_vno_vlan0_result $fr64_fl1024_kernel_13_vno_vlan0_threshold
if [[ $fr64_fl1024_kernel_13_vno_vlan0_result -ge $fr64_fl1024_kernel_13_vno_vlan0_threshold ]]; then echo "Result: PASS Threshold: $fr64_fl1024_kernel_13_vno_vlan0_threshold, Result: $fr64_fl1024_kernel_13_vno_vlan0_result" | tee -a pass_fail.txt; else echo "Result: FAIL Threshold: $fr64_fl1024_kernel_13_vno_vlan0_threshold, Result: $fr64_fl1024_kernel_13_vno_vlan0_result" | tee -a pass_fail.txt; fi
echo "Difference between actual result and threshold: $delta ($pct%)" | tee -a pass_fail.txt


# frame size=128, flows=1024, loss-rate=0
fr128_fl1024_123_vno_vlan11_threshold=2846454
fr128_fl1024_143_vno_vlan11_threshold=5508501
fr128_fl1024_245_vno_vlan11_threshold=5531634
fr128_fl1024_489_vno_vlan11_threshold=10817131
fr128_fl1024_123_vyes_vlan0_threshold=2681148
fr128_fl1024_143_vyes_vlan0_threshold=6194070
fr128_fl1024_245_vyes_vlan0_threshold=6141253
fr128_fl1024_489_vyes_vlan0_threshold=10281561

# ovs_dpdk_vhostuser_pvp vIOMMU=no vlan=11 frame=128
fr128_fl1024_123_vno_vlan11_result=$(grep -A8 'jq --arg sz 128 --arg fl 1024' $result_file | grep 'result=' | grep vlan11 | awk -F "," '{print $2}' | awk -F "." '{print $1}')
fr128_fl1024_143_vno_vlan11_result=$(grep -A8 'jq --arg sz 128 --arg fl 1024' $result_file | grep 'result=' | grep vlan11 | awk -F "," '{print $4}' | awk -F "." '{print $1}')
fr128_fl1024_245_vno_vlan11_result=$(grep -A8 'jq --arg sz 128 --arg fl 1024' $result_file | grep 'result=' | grep vlan11 | awk -F "," '{print $6}' | awk -F "." '{print $1}')
fr128_fl1024_489_vno_vlan11_result=$(grep -A8 'jq --arg sz 128 --arg fl 1024' $result_file | grep 'result=' | grep vlan11 | awk -F "," '{print $8}' | awk -F "." '{print $1}')

# ovs_dpdk_vhostuser_pvp vIOMMU=yes vlan=0 frame=128
fr128_fl1024_123_vyes_vlan0_result=$(grep -A8 'jq --arg sz 128 --arg fl 1024' $result_file | grep 'result=' | grep vlan0 | awk -F "," '{print $10}' | awk -F "." '{print $1}')
fr128_fl1024_143_vyes_vlan0_result=$(grep -A8 'jq --arg sz 128 --arg fl 1024' $result_file | grep 'result=' | grep vlan0 | awk -F "," '{print $12}' | awk -F "." '{print $1}')
fr128_fl1024_245_vyes_vlan0_result=$(grep -A8 'jq --arg sz 128 --arg fl 1024' $result_file | grep 'result=' | grep vlan0 | awk -F "," '{print $14}' | awk -F "." '{print $1}')
fr128_fl1024_489_vyes_vlan0_result=$(grep -A8 'jq --arg sz 128 --arg fl 1024' $result_file | grep 'result=' | grep vlan0 | awk -F "," '{print $16}' | awk -F "." '{print $1}')

echo "" | tee -a pass_fail.txt
echo "Test: ovs_dpdk_vhostuser_pvp vIOMMU=no vlan=11 frame=128 queues=1 pmds=2 vcpus=3" | tee -a pass_fail.txt
get_delta_values $fr128_fl1024_123_vno_vlan11_result $fr128_fl1024_123_vno_vlan11_threshold
if [[ $fr128_fl1024_123_vno_vlan11_result -ge $fr128_fl1024_123_vno_vlan11_threshold ]]; then echo "Result: PASS Threshold: $fr128_fl1024_123_vno_vlan11_threshold, Result: $fr128_fl1024_123_vno_vlan11_result" | tee -a pass_fail.txt; else echo "Result: FAIL Threshold: $fr128_fl1024_123_vno_vlan11_threshold, Result: $fr128_fl1024_123_vno_vlan11_result" | tee -a pass_fail.txt; fi
echo "Difference between actual result and threshold: $delta ($pct%)" | tee -a pass_fail.txt

echo "" | tee -a pass_fail.txt
echo "Test: ovs_dpdk_vhostuser_pvp vIOMMU=no vlan=11 frame=128 queues=1 pmds=4 vcpus=3" | tee -a pass_fail.txt
get_delta_values $fr128_fl1024_143_vno_vlan11_result $fr128_fl1024_143_vno_vlan11_threshold
if [[ $fr128_fl1024_143_vno_vlan11_result -ge $fr128_fl1024_143_vno_vlan11_threshold ]]; then echo "Result: PASS Threshold: $fr128_fl1024_143_vno_vlan11_threshold, Result: $fr128_fl1024_143_vno_vlan11_result" | tee -a pass_fail.txt; else echo "Result: FAIL Threshold: $fr128_fl1024_143_vno_vlan11_threshold, Result: $fr128_fl1024_143_vno_vlan11_result" | tee -a pass_fail.txt; fi
echo "Difference between actual result and threshold: $delta ($pct%)" | tee -a pass_fail.txt

echo "" | tee -a pass_fail.txt
echo "Test: ovs_dpdk_vhostuser_pvp vIOMMU=no vlan=11 frame=128 queues=2 pmds=4 vcpus=5" | tee -a pass_fail.txt
get_delta_values $fr128_fl1024_245_vno_vlan11_result $fr128_fl1024_245_vno_vlan11_threshold
if [[ $fr128_fl1024_245_vno_vlan11_result -ge $fr128_fl1024_245_vno_vlan11_threshold ]]; then echo "Result: PASS Threshold: $fr128_fl1024_245_vno_vlan11_threshold, Result: $fr128_fl1024_245_vno_vlan11_result" | tee -a pass_fail.txt; else echo "Result: FAIL Threshold: $fr128_fl1024_245_vno_vlan11_threshold, Result: $fr128_fl1024_245_vno_vlan11_result" | tee -a pass_fail.txt; fi
echo "Difference between actual result and threshold: $delta ($pct%)" | tee -a pass_fail.txt

echo "" | tee -a pass_fail.txt
echo "Test: ovs_dpdk_vhostuser_pvp vIOMMU=no vlan=11 frame=128 queues=4 pmds=8 vcpus=9" | tee -a pass_fail.txt
get_delta_values $fr128_fl1024_489_vno_vlan11_result $fr128_fl1024_489_vno_vlan11_threshold
if [[ $fr128_fl1024_489_vno_vlan11_result -ge $fr128_fl1024_489_vno_vlan11_threshold ]]; then echo "Result: PASS Threshold: $fr128_fl1024_489_vno_vlan11_threshold, Result: $fr128_fl1024_489_vno_vlan11_result" | tee -a pass_fail.txt; else echo "Result: FAIL Threshold: $fr128_fl1024_489_vno_vlan11_threshold, Result: $fr128_fl1024_489_vno_vlan11_result" | tee -a pass_fail.txt; fi
echo "Difference between actual result and threshold: $delta ($pct%)" | tee -a pass_fail.txt

echo "" | tee -a pass_fail.txt
echo "Test: ovs_dpdk_vhostuser_pvp vIOMMU=yes vlan=0 frame=128 queues=1 pmds=2 vcpus=3" | tee -a pass_fail.txt
get_delta_values $fr128_fl1024_123_vyes_vlan0_result $fr128_fl1024_123_vyes_vlan0_threshold
if [[ $fr128_fl1024_123_vyes_vlan0_result -ge $fr128_fl1024_123_vyes_vlan0_threshold ]]; then echo "Result: PASS Threshold: $fr128_fl1024_123_vyes_vlan0_threshold, Result: $fr128_fl1024_123_vyes_vlan0_result" | tee -a pass_fail.txt; else echo "Result: FAIL Threshold: $fr128_fl1024_123_vyes_vlan0_threshold, Result: $fr128_fl1024_123_vyes_vlan0_result" | tee -a pass_fail.txt; fi
echo "Difference between actual result and threshold: $delta ($pct%)" | tee -a pass_fail.txt

echo "" | tee -a pass_fail.txt
echo "Test: ovs_dpdk_vhostuser_pvp vIOMMU=yes vlan=0 frame=128 queues=1 pmds=4 vcpus=3" | tee -a pass_fail.txt
get_delta_values $fr128_fl1024_143_vyes_vlan0_result $fr128_fl1024_143_vyes_vlan0_threshold
if [[ $fr128_fl1024_143_vyes_vlan0_result -ge $fr128_fl1024_143_vyes_vlan0_threshold ]]; then echo "Result: PASS Threshold: $fr128_fl1024_143_vyes_vlan0_threshold, Result: $fr128_fl1024_143_vyes_vlan0_result" | tee -a pass_fail.txt; else echo "Result: FAIL Threshold: $fr128_fl1024_143_vyes_vlan0_threshold, Result: $fr128_fl1024_143_vyes_vlan0_result" | tee -a pass_fail.txt; fi
echo "Difference between actual result and threshold: $delta ($pct%)" | tee -a pass_fail.txt

echo "" | tee -a pass_fail.txt
echo "Test: ovs_dpdk_vhostuser_pvp vIOMMU=yes vlan=0 frame=128 queues=2 pmds=4 vcpus=5" | tee -a pass_fail.txt
get_delta_values $fr128_fl1024_245_vyes_vlan0_result $fr128_fl1024_245_vyes_vlan0_threshold
if [[ $fr128_fl1024_245_vyes_vlan0_result -ge $fr128_fl1024_245_vyes_vlan0_threshold ]]; then echo "Result: PASS Threshold: $fr128_fl1024_245_vyes_vlan0_threshold, Result: $fr128_fl1024_245_vyes_vlan0_result" | tee -a pass_fail.txt; else echo "Result: FAIL Threshold: $fr128_fl1024_245_vyes_vlan0_threshold, Result: $fr128_fl1024_245_vyes_vlan0_result" | tee -a pass_fail.txt; fi
echo "Difference between actual result and threshold: $delta ($pct%)" | tee -a pass_fail.txt

echo "" | tee -a pass_fail.txt
echo "Test: ovs_dpdk_vhostuser_pvp vIOMMU=yes vlan=0 frame=128 queues=4 pmds=8 vcpus=9" | tee -a pass_fail.txt
get_delta_values $fr128_fl1024_489_vyes_vlan0_result $fr128_fl1024_489_vyes_vlan0_threshold
if [[ $fr128_fl1024_489_vyes_vlan0_result -ge $fr128_fl1024_489_vyes_vlan0_threshold ]]; then echo "Result: PASS Threshold: $fr128_fl1024_489_vyes_vlan0_threshold, Result: $fr128_fl1024_489_vyes_vlan0_result" | tee -a pass_fail.txt; else echo "Result: FAIL Threshold: $fr128_fl1024_489_vyes_vlan0_threshold, Result: $fr128_fl1024_489_vyes_vlan0_result" | tee -a pass_fail.txt; fi
echo "Difference between actual result and threshold: $delta ($pct%)" | tee -a pass_fail.txt


# frame size=256, flows=1024, loss-rate=0
fr256_fl1024_123_vno_vlan11_threshold=2693700
fr256_fl1024_143_vno_vlan11_threshold=5569695
fr256_fl1024_245_vno_vlan11_threshold=5243224
fr256_fl1024_489_vno_vlan11_threshold=9979452
fr256_fl1024_123_vyes_vlan0_threshold=2518092
fr256_fl1024_143_vyes_vlan0_threshold=5879763
fr256_fl1024_245_vyes_vlan0_threshold=5911685
fr256_fl1024_489_vyes_vlan0_threshold=9431380

# ovs_dpdk_vhostuser_pvp vIOMMU=no vlan=11 frame=256
fr256_fl1024_123_vno_vlan11_result=$(grep -A8 'jq --arg sz 256 --arg fl 1024' $result_file | grep 'result=' | grep vlan11 | awk -F "," '{print $2}' | awk -F "." '{print $1}')
fr256_fl1024_143_vno_vlan11_result=$(grep -A8 'jq --arg sz 256 --arg fl 1024' $result_file | grep 'result=' | grep vlan11 | awk -F "," '{print $4}' | awk -F "." '{print $1}')
fr256_fl1024_245_vno_vlan11_result=$(grep -A8 'jq --arg sz 256 --arg fl 1024' $result_file | grep 'result=' | grep vlan11 | awk -F "," '{print $6}' | awk -F "." '{print $1}')
fr256_fl1024_489_vno_vlan11_result=$(grep -A8 'jq --arg sz 256 --arg fl 1024' $result_file | grep 'result=' | grep vlan11 | awk -F "," '{print $8}' | awk -F "." '{print $1}')
fr256_fl1024_123_vyes_vlan0_result=$(grep -A8 'jq --arg sz 256 --arg fl 1024' $result_file | grep 'result=' | grep vlan0 | awk -F "," '{print $10}' | awk -F "." '{print $1}')

# ovs_dpdk_vhostuser_pvp vIOMMU=yes vlan=0 frame=256 
fr256_fl1024_143_vyes_vlan0_result=$(grep -A8 'jq --arg sz 256 --arg fl 1024' $result_file | grep 'result=' | grep vlan0 | awk -F "," '{print $12}' | awk -F "." '{print $1}')
fr256_fl1024_245_vyes_vlan0_result=$(grep -A8 'jq --arg sz 256 --arg fl 1024' $result_file | grep 'result=' | grep vlan0 | awk -F "," '{print $14}' | awk -F "." '{print $1}')
fr256_fl1024_489_vyes_vlan0_result=$(grep -A8 'jq --arg sz 256 --arg fl 1024' $result_file | grep 'result=' | grep vlan0 | awk -F "," '{print $16}' | awk -F "." '{print $1}')

echo "" | tee -a pass_fail.txt
echo "Test: ovs_dpdk_vhostuser_pvp vIOMMU=no vlan=11 frame=256 queues=1 pmds=2 vcpus=3" | tee -a pass_fail.txt
get_delta_values $fr256_fl1024_123_vno_vlan11_result $fr256_fl1024_123_vno_vlan11_threshold
if [[ $fr256_fl1024_123_vno_vlan11_result -ge $fr256_fl1024_123_vno_vlan11_threshold ]]; then echo "Result: PASS Threshold: $fr256_fl1024_123_vno_vlan11_threshold, Result: $fr256_fl1024_123_vno_vlan11_result" | tee -a pass_fail.txt; else echo "Result: FAIL Threshold: $fr256_fl1024_123_vno_vlan11_threshold, Result: $fr256_fl1024_123_vno_vlan11_result" | tee -a pass_fail.txt; fi
echo "Difference between actual result and threshold: $delta ($pct%)" | tee -a pass_fail.txt

echo "" | tee -a pass_fail.txt
echo "Test: ovs_dpdk_vhostuser_pvp vIOMMU=no vlan=11 frame=256 queues=1 pmds=4 vcpus=3" | tee -a pass_fail.txt
get_delta_values $fr256_fl1024_143_vno_vlan11_result $fr256_fl1024_143_vno_vlan11_threshold
if [[ $fr256_fl1024_143_vno_vlan11_result -ge $fr256_fl1024_143_vno_vlan11_threshold ]]; then echo "Result: PASS Threshold: $fr256_fl1024_143_vno_vlan11_threshold, Result: $fr256_fl1024_143_vno_vlan11_result" | tee -a pass_fail.txt; else echo "Result: FAIL Threshold: $fr256_fl1024_143_vno_vlan11_threshold, Result: $fr256_fl1024_143_vno_vlan11_result" | tee -a pass_fail.txt; fi
echo "Difference between actual result and threshold: $delta ($pct%)" | tee -a pass_fail.txt

echo "" | tee -a pass_fail.txt
echo "Test: ovs_dpdk_vhostuser_pvp vIOMMU=no vlan=11 frame=256 queues=2 pmds=4 vcpus=5" | tee -a pass_fail.txt
get_delta_values $fr256_fl1024_245_vno_vlan11_result $fr256_fl1024_245_vno_vlan11_threshold
if [[ $fr256_fl1024_245_vno_vlan11_result -ge $fr256_fl1024_245_vno_vlan11_threshold ]]; then echo "Result: PASS Threshold: $fr256_fl1024_245_vno_vlan11_threshold, Result: $fr256_fl1024_245_vno_vlan11_result" | tee -a pass_fail.txt; else echo "Result: FAIL Threshold: $fr256_fl1024_245_vno_vlan11_threshold, Result: $fr256_fl1024_245_vno_vlan11_result" | tee -a pass_fail.txt; fi
echo "Difference between actual result and threshold: $delta ($pct%)" | tee -a pass_fail.txt

echo "" | tee -a pass_fail.txt
echo "Test: ovs_dpdk_vhostuser_pvp vIOMMU=no vlan=11 frame=256 queues=4 pmds=8 vcpus=9" | tee -a pass_fail.txt
get_delta_values $fr256_fl1024_489_vno_vlan11_result $fr256_fl1024_489_vno_vlan11_threshold
if [[ $fr256_fl1024_489_vno_vlan11_result -ge $fr256_fl1024_489_vno_vlan11_threshold ]]; then echo "Result: PASS Threshold: $fr256_fl1024_489_vno_vlan11_threshold, Result: $fr256_fl1024_489_vno_vlan11_result" | tee -a pass_fail.txt; else echo "Result: FAIL Threshold: $fr256_fl1024_489_vno_vlan11_threshold, Result: $fr256_fl1024_489_vno_vlan11_result" | tee -a pass_fail.txt; fi
echo "Difference between actual result and threshold: $delta ($pct%)" | tee -a pass_fail.txt

echo "" | tee -a pass_fail.txt
echo "Test: ovs_dpdk_vhostuser_pvp vIOMMU=yes vlan=0 frame=256 queues=1 pmds=2 vcpus=3" | tee -a pass_fail.txt
get_delta_values $fr256_fl1024_123_vyes_vlan0_result $fr256_fl1024_123_vyes_vlan0_threshold
if [[ $fr256_fl1024_123_vyes_vlan0_result -ge $fr256_fl1024_123_vyes_vlan0_threshold ]]; then echo "Result: PASS Threshold: $fr256_fl1024_123_vyes_vlan0_threshold, Result: $fr256_fl1024_123_vyes_vlan0_result" | tee -a pass_fail.txt; else echo "Result: FAIL Threshold: $fr256_fl1024_123_vyes_vlan0_threshold, Result: $fr256_fl1024_123_vyes_vlan0_result" | tee -a pass_fail.txt; fi
echo "Difference between actual result and threshold: $delta ($pct%)" | tee -a pass_fail.txt

echo "" | tee -a pass_fail.txt
echo "Test: ovs_dpdk_vhostuser_pvp vIOMMU=yes vlan=0 frame=256 queues=1 pmds=4 vcpus=3" | tee -a pass_fail.txt
get_delta_values $fr256_fl1024_143_vyes_vlan0_result $fr256_fl1024_143_vyes_vlan0_threshold
if [[ $fr256_fl1024_143_vyes_vlan0_result -ge $fr256_fl1024_143_vyes_vlan0_threshold ]]; then echo "Result: PASS Threshold: $fr256_fl1024_143_vyes_vlan0_threshold, Result: $fr256_fl1024_143_vyes_vlan0_result" | tee -a pass_fail.txt; else echo "Result: FAIL Threshold: $fr256_fl1024_143_vyes_vlan0_threshold, Result: $fr256_fl1024_143_vyes_vlan0_result" | tee -a pass_fail.txt; fi
echo "Difference between actual result and threshold: $delta ($pct%)" | tee -a pass_fail.txt

echo "" | tee -a pass_fail.txt
echo "Test: ovs_dpdk_vhostuser_pvp vIOMMU=yes vlan=0 frame=256 queues=2 pmds=4 vcpus=5" | tee -a pass_fail.txt
get_delta_values $fr256_fl1024_245_vyes_vlan0_result $fr256_fl1024_245_vyes_vlan0_threshold
if [[ $fr256_fl1024_245_vyes_vlan0_result -ge $fr256_fl1024_245_vyes_vlan0_threshold ]]; then echo "Result: PASS Threshold: $fr256_fl1024_245_vyes_vlan0_threshold, Result: $fr256_fl1024_245_vyes_vlan0_result" | tee -a pass_fail.txt; else echo "Result: FAIL Threshold: $fr256_fl1024_245_vyes_vlan0_threshold, Result: $fr256_fl1024_245_vyes_vlan0_result" | tee -a pass_fail.txt; fi
echo "Difference between actual result and threshold: $delta ($pct%)" | tee -a pass_fail.txt

echo "" | tee -a pass_fail.txt
echo "Test: ovs_dpdk_vhostuser_pvp vIOMMU=yes vlan=0 frame=256 queues=4 pmds=8 vcpus=9" | tee -a pass_fail.txt
get_delta_values $fr256_fl1024_489_vyes_vlan0_result $fr256_fl1024_489_vyes_vlan0_threshold
if [[ $fr256_fl1024_489_vyes_vlan0_result -ge $fr256_fl1024_489_vyes_vlan0_threshold ]]; then echo "Result: PASS Threshold: $fr256_fl1024_489_vyes_vlan0_threshold, Result: $fr256_fl1024_489_vyes_vlan0_result" | tee -a pass_fail.txt; else echo "Result: FAIL Threshold: $fr256_fl1024_489_vyes_vlan0_threshold, Result: $fr256_fl1024_489_vyes_vlan0_result" | tee -a pass_fail.txt; fi
echo "Difference between actual result and threshold: $delta ($pct%)" | tee -a pass_fail.txt


# frame size=1500, flows=1024, loss-rate=0

fr1500_fl1024_123_vno_vlan11_threshold=1533901
fr1500_fl1024_143_vno_vlan11_threshold=2884844
fr1500_fl1024_245_vno_vlan11_threshold=2794363
fr1500_fl1024_489_vno_vlan11_threshold=3480766
fr1500_fl1024_123_vyes_vlan0_threshold=1342070
fr1500_fl1024_143_vyes_vlan0_threshold=2980076
fr1500_fl1024_245_vyes_vlan0_threshold=2907351
fr1500_fl1024_489_vyes_vlan0_threshold=3149420

# ovs_dpdk_vhostuser_pvp vIOMMU=no vlan=11 frame=1500 
fr1500_fl1024_123_vno_vlan11_result=$(grep -A8 'jq --arg sz 1500 --arg fl 1024' $result_file | grep 'result=' | grep vlan11 | awk -F "," '{print $2}' | awk -F "." '{print $1}')
fr1500_fl1024_143_vno_vlan11_result=$(grep -A8 'jq --arg sz 1500 --arg fl 1024' $result_file | grep 'result=' | grep vlan11 | awk -F "," '{print $4}' | awk -F "." '{print $1}')
fr1500_fl1024_245_vno_vlan11_result=$(grep -A8 'jq --arg sz 1500 --arg fl 1024' $result_file | grep 'result=' | grep vlan11 | awk -F "," '{print $6}' | awk -F "." '{print $1}')
fr1500_fl1024_489_vno_vlan11_result=$(grep -A8 'jq --arg sz 1500 --arg fl 1024' $result_file | grep 'result=' | grep vlan11 | awk -F "," '{print $8}' | awk -F "." '{print $1}')

# ovs_dpdk_vhostuser_pvp vIOMMU=yes vlan=0 frame=1500
fr1500_fl1024_123_vyes_vlan0_result=$(grep -A8 'jq --arg sz 1500 --arg fl 1024' $result_file | grep 'result=' | grep vlan0 | awk -F "," '{print $10}' | awk -F "." '{print $1}')
fr1500_fl1024_143_vyes_vlan0_result=$(grep -A8 'jq --arg sz 1500 --arg fl 1024' $result_file | grep 'result=' | grep vlan0 | awk -F "," '{print $12}' | awk -F "." '{print $1}')
fr1500_fl1024_245_vyes_vlan0_result=$(grep -A8 'jq --arg sz 1500 --arg fl 1024' $result_file | grep 'result=' | grep vlan0 | awk -F "," '{print $14}' | awk -F "." '{print $1}')
fr1500_fl1024_489_vyes_vlan0_result=$(grep -A8 'jq --arg sz 1500 --arg fl 1024' $result_file | grep 'result=' | grep vlan0 | awk -F "," '{print $16}' | awk -F "." '{print $1}')

echo "" | tee -a pass_fail.txt
echo "Test: ovs_dpdk_vhostuser_pvp vIOMMU=no vlan=11 frame=1500 queues=1 pmds=2 vcpus=3" | tee -a pass_fail.txt
get_delta_values $fr256_fl1024_245_vyes_vlan0_result $fr256_fl1024_245_vyes_vlan0_threshold
if [[ $fr1500_fl1024_123_vno_vlan11_result -ge $fr1500_fl1024_123_vno_vlan11_threshold ]]; then echo "Result: PASS Threshold: $fr1500_fl1024_123_vno_vlan11_threshold, Result: $fr1500_fl1024_123_vno_vlan11_result" | tee -a pass_fail.txt; else echo "Result: FAIL Threshold: $fr1500_fl1024_123_vno_vlan11_threshold, Result: $fr1500_fl1024_123_vno_vlan11_result" | tee -a pass_fail.txt; fi
echo "Difference between actual result and threshold: $delta ($pct%)" | tee -a pass_fail.txt

echo "" | tee -a pass_fail.txt
echo "Test: ovs_dpdk_vhostuser_pvp vIOMMU=no vlan=11 frame=1500 queues=1 pmds=4 vcpus=3" | tee -a pass_fail.txt
get_delta_values $fr1500_fl1024_143_vno_vlan11_result $fr1500_fl1024_143_vno_vlan11_threshold
if [[ $fr1500_fl1024_143_vno_vlan11_result -ge $fr1500_fl1024_143_vno_vlan11_threshold ]]; then echo "Result: PASS Threshold: $fr1500_fl1024_143_vno_vlan11_threshold, Result: $fr1500_fl1024_143_vno_vlan11_result" | tee -a pass_fail.txt; else echo "Result: FAIL Threshold: $fr1500_fl1024_143_vno_vlan11_threshold, Result: $fr1500_fl1024_143_vno_vlan11_result" | tee -a pass_fail.txt; fi
echo "Difference between actual result and threshold: $delta ($pct%)" | tee -a pass_fail.txt

echo "" | tee -a pass_fail.txt
echo "Test: ovs_dpdk_vhostuser_pvp vIOMMU=no vlan=11 frame=1500 queues=2 pmds=4 vcpus=5" | tee -a pass_fail.txt
get_delta_values $fr1500_fl1024_245_vno_vlan11_result $fr1500_fl1024_245_vno_vlan11_threshold
if [[ $fr1500_fl1024_245_vno_vlan11_result -ge $fr1500_fl1024_245_vno_vlan11_threshold ]]; then echo "Result: PASS Threshold: $fr1500_fl1024_245_vno_vlan11_threshold, Result: $fr1500_fl1024_245_vno_vlan11_result" | tee -a pass_fail.txt; else echo "Result: FAIL Threshold: $fr1500_fl1024_245_vno_vlan11_threshold, Result: $fr1500_fl1024_245_vno_vlan11_result" | tee -a pass_fail.txt; fi
echo "Difference between actual result and threshold: $delta ($pct%)" | tee -a pass_fail.txt

echo "" | tee -a pass_fail.txt
echo "Test: ovs_dpdk_vhostuser_pvp vIOMMU=no vlan=11 frame=1500 queues=4 pmds=8 vcpus=9" | tee -a pass_fail.txt
get_delta_values $fr1500_fl1024_489_vno_vlan11_result $fr1500_fl1024_489_vno_vlan11_threshold
if [[ $fr1500_fl1024_489_vno_vlan11_result -ge $fr1500_fl1024_489_vno_vlan11_threshold ]]; then echo "Result: PASS Threshold: $fr1500_fl1024_489_vno_vlan11_threshold, Result: $fr1500_fl1024_489_vno_vlan11_result" | tee -a pass_fail.txt; else echo "Result: FAIL Threshold: $fr1500_fl1024_489_vno_vlan11_threshold, Result: $fr1500_fl1024_489_vno_vlan11_result" | tee -a pass_fail.txt; fi
echo "Difference between actual result and threshold: $delta ($pct%)" | tee -a pass_fail.txt

echo "" | tee -a pass_fail.txt
echo "Test: ovs_dpdk_vhostuser_pvp vIOMMU=yes vlan=0 frame=1500 queues=1 pmds=2 vcpus=3" | tee -a pass_fail.txt
get_delta_values $fr1500_fl1024_123_vyes_vlan0_result $fr1500_fl1024_123_vyes_vlan0_threshold
if [[ $fr1500_fl1024_123_vyes_vlan0_result -ge $fr1500_fl1024_123_vyes_vlan0_threshold ]]; then echo "Result: PASS Threshold: $fr1500_fl1024_123_vyes_vlan0_threshold, Result: $fr1500_fl1024_123_vyes_vlan0_result" | tee -a pass_fail.txt; else echo "Result: FAIL Threshold: $fr1500_fl1024_123_vyes_vlan0_threshold, Result: $fr1500_fl1024_123_vyes_vlan0_result" | tee -a pass_fail.txt; fi
echo "Difference between actual result and threshold: $delta ($pct%)" | tee -a pass_fail.txt

echo "" | tee -a pass_fail.txt
echo "Test: ovs_dpdk_vhostuser_pvp vIOMMU=yes vlan=0 frame=1500 queues=1 pmds=4 vcpus=3" | tee -a pass_fail.txt
get_delta_values $fr1500_fl1024_143_vyes_vlan0_result $fr1500_fl1024_143_vyes_vlan0_threshold
if [[ $fr1500_fl1024_143_vyes_vlan0_result -ge $fr1500_fl1024_143_vyes_vlan0_threshold ]]; then echo "Result: PASS Threshold: $fr1500_fl1024_143_vyes_vlan0_threshold, Result: $fr1500_fl1024_143_vyes_vlan0_result" | tee -a pass_fail.txt; else echo "Result: FAIL Threshold: $fr1500_fl1024_143_vyes_vlan0_threshold, Result: $fr1500_fl1024_143_vyes_vlan0_result" | tee -a pass_fail.txt; fi
echo "Difference between actual result and threshold: $delta ($pct%)" | tee -a pass_fail.txt

echo "" | tee -a pass_fail.txt
echo "Test: ovs_dpdk_vhostuser_pvp vIOMMU=yes vlan=0 frame=1500 queues=2 pmds=4 vcpus=5" | tee -a pass_fail.txt
get_delta_values $fr1500_fl1024_245_vyes_vlan0_result $fr1500_fl1024_245_vyes_vlan0_threshold
if [[ $fr1500_fl1024_245_vyes_vlan0_result -ge $fr1500_fl1024_245_vyes_vlan0_threshold ]]; then echo "Result: PASS Threshold: $fr1500_fl1024_245_vyes_vlan0_threshold, Result: $fr1500_fl1024_245_vyes_vlan0_result" | tee -a pass_fail.txt; else echo "Result: FAIL Threshold: $fr1500_fl1024_245_vyes_vlan0_threshold, Result: $fr1500_fl1024_245_vyes_vlan0_result" | tee -a pass_fail.txt; fi
echo "Difference between actual result and threshold: $delta ($pct%)" | tee -a pass_fail.txt

echo "" | tee -a pass_fail.txt
echo "Test: ovs_dpdk_vhostuser_pvp vIOMMU=yes vlan=0 frame=1500 queues=4 pmds=8 vcpus=9" | tee -a pass_fail.txt
get_delta_values $fr1500_fl1024_489_vyes_vlan0_result $fr1500_fl1024_489_vyes_vlan0_threshold
if [[ $fr1500_fl1024_489_vyes_vlan0_result -ge $fr1500_fl1024_489_vyes_vlan0_threshold ]]; then echo "Result: PASS Threshold: $fr1500_fl1024_489_vyes_vlan0_threshold, Result: $fr1500_fl1024_489_vyes_vlan0_result" | tee -a pass_fail.txt; else echo "Result: FAIL Threshold: $fr1500_fl1024_489_vyes_vlan0_threshold, Result: $fr1500_fl1024_489_vyes_vlan0_result" | tee -a pass_fail.txt; fi
echo "Difference between actual result and threshold: $delta ($pct%)" | tee -a pass_fail.txt


# sriov_pvp
# Frame=1500

fr1500_fl1024_sriov_13_vyes_vlan0_threshold=4419072
fr1500_fl1024_sriov_13_vyes_vlan0_result=$(grep -A8 'jq --arg sz 1500 --arg fl 1024' $result_file | grep 'result=' | grep vlan0 | awk -F "," '{print $18}' | awk -F "." '{print $1}')

echo "" | tee -a pass_fail.txt
echo "Test: sriov_pvp vIOMMU=yes vlan=0 frame=1500 queues=1 vcpus=3" | tee -a pass_fail.txt
get_delta_values $fr1500_fl1024_sriov_13_vyes_vlan0_result $fr1500_fl1024_sriov_13_vyes_vlan0_threshold
if [[ $fr1500_fl1024_sriov_13_vyes_vlan0_result -ge $fr1500_fl1024_sriov_13_vyes_vlan0_threshold ]]; then echo "Result: PASS Threshold: $fr1500_fl1024_sriov_13_vyes_vlan0_threshold, Result: $fr1500_fl1024_sriov_13_vyes_vlan0_result" | tee -a pass_fail.txt; else echo "Result: FAIL Threshold: $fr1500_fl1024_sriov_13_vyes_vlan0_threshold, Result: $fr1500_fl1024_sriov_13_vyes_vlan0_result" | tee -a pass_fail.txt; fi
echo "Difference between actual result and threshold: $delta ($pct%)" | tee -a pass_fail.txt


# frame size=2000, flows=1024, loss-rate=0
fr2000_fl1024_123_vno_vlan11_threshold=1303543
fr2000_fl1024_143_vno_vlan11_threshold=2451125
fr2000_fl1024_123_vyes_vlan0_threshold=1158367
fr2000_fl1024_143_vyes_vlan0_threshold=2513781

# ovs_dpdk_vhostuser_pvp vIOMMU=no vlan=11 frame=2000
fr2000_fl1024_123_vno_vlan11_result=$(grep -A8 'jq --arg sz 2000 --arg fl 1024' $result_file | grep 'result=' | grep vlan11 | awk -F "," '{print $2}' | awk -F "." '{print $1}')
fr2000_fl1024_143_vno_vlan11_result=$(grep -A8 'jq --arg sz 2000 --arg fl 1024' $result_file | grep 'result=' | grep vlan11 | awk -F "," '{print $4}' | awk -F "." '{print $1}')

# ovs_dpdk_vhostuser_pvp vIOMMU=yes vlan=0 frame=2000
fr2000_fl1024_123_vyes_vlan0_result=$(grep -A8 'jq --arg sz 2000 --arg fl 1024' $result_file | grep 'result=' | grep vlan0 | awk -F "," '{print $6}' | awk -F "." '{print $1}')
fr2000_fl1024_143_vyes_vlan0_result=$(grep -A8 'jq --arg sz 2000 --arg fl 1024' $result_file | grep 'result=' | grep vlan0 | awk -F "," '{print $8}' | awk -F "." '{print $1}')

echo "" | tee -a pass_fail.txt
echo "Test: ovs_dpdk_vhostuser_pvp vIOMMU=no vlan=11 frame=2000 queues=1 pmds=2 vcpus=3" | tee -a pass_fail.txt
get_delta_values $fr2000_fl1024_123_vno_vlan11_result $fr2000_fl1024_123_vno_vlan11_threshold
if [[ $fr2000_fl1024_123_vno_vlan11_result -ge $fr2000_fl1024_123_vno_vlan11_threshold ]]; then echo "Result: PASS Threshold: $fr2000_fl1024_123_vno_vlan11_threshold, Result: $fr2000_fl1024_123_vno_vlan11_result" | tee -a pass_fail.txt; else echo "Result: FAIL Threshold: $fr2000_fl1024_123_vno_vlan11_threshold, Result: $fr2000_fl1024_123_vno_vlan11_result" | tee -a pass_fail.txt; fi
echo "Difference between actual result and threshold: $delta ($pct%)" | tee -a pass_fail.txt

echo "" | tee -a pass_fail.txt
echo "Test: ovs_dpdk_vhostuser_pvp vIOMMU=no vlan=11 frame=2000 queues=1 pmds=4 vcpus=3" | tee -a pass_fail.txt
get_delta_values $fr2000_fl1024_143_vno_vlan11_result $fr2000_fl1024_143_vno_vlan11_threshold
if [[ $fr2000_fl1024_143_vno_vlan11_result -ge $fr2000_fl1024_143_vno_vlan11_threshold ]]; then echo "Result: PASS Threshold: $fr2000_fl1024_143_vno_vlan11_threshold, Result: $fr2000_fl1024_143_vno_vlan11_result" | tee -a pass_fail.txt; else echo "Result: FAIL Threshold: $fr2000_fl1024_143_vno_vlan11_threshold, Result: $fr2000_fl1024_143_vno_vlan11_result" | tee -a pass_fail.txt; fi
echo "Difference between actual result and threshold: $delta ($pct%)" | tee -a pass_fail.txt

echo "" | tee -a pass_fail.txt
echo "Test: ovs_dpdk_vhostuser_pvp vIOMMU=yes vlan=0 frame=2000 queues=1 pmds=2 vcpus=3" | tee -a pass_fail.txt
get_delta_values $fr2000_fl1024_123_vyes_vlan0_result $fr2000_fl1024_123_vyes_vlan0_threshold
if [[ $fr2000_fl1024_123_vyes_vlan0_result -ge $fr2000_fl1024_123_vyes_vlan0_threshold ]]; then echo "Result: PASS Threshold: $fr2000_fl1024_123_vyes_vlan0_threshold, Result: $fr2000_fl1024_123_vyes_vlan0_result" | tee -a pass_fail.txt; else echo "Result: FAIL Threshold: $fr2000_fl1024_123_vyes_vlan0_threshold, Result: $fr2000_fl1024_123_vyes_vlan0_result" | tee -a pass_fail.txt; fi
echo "Difference between actual result and threshold: $delta ($pct%)" | tee -a pass_fail.txt

echo "" | tee -a pass_fail.txt
echo "Test: ovs_dpdk_vhostuser_pvp vIOMMU=yes vlan=0 frame=2000 queues=1 pmds=4 vcpus=3" | tee -a pass_fail.txt
get_delta_values $fr2000_fl1024_143_vyes_vlan0_result $fr2000_fl1024_143_vyes_vlan0_threshold
if [[ $fr2000_fl1024_143_vyes_vlan0_result -ge $fr2000_fl1024_143_vyes_vlan0_threshold ]]; then echo "Result: PASS Threshold: $fr2000_fl1024_143_vyes_vlan0_threshold, Result: $fr2000_fl1024_143_vyes_vlan0_result" | tee -a pass_fail.txt; else echo "Result: FAIL Threshold: $fr2000_fl1024_143_vyes_vlan0_threshold, Result: $fr2000_fl1024_143_vyes_vlan0_result" | tee -a pass_fail.txt; fi
echo "Difference between actual result and threshold: $delta ($pct%)" | tee -a pass_fail.txt


# frame size=9200, flows=1024, loss-rate=0

fr9200_fl1024_123_vno_vlan11_threshold=367944
fr9200_fl1024_143_vno_vlan11_threshold=492589
fr9200_fl1024_123_vyes_vlan0_threshold=357393
fr9200_fl1024_143_vyes_vlan0_threshold=528866

# ovs_dpdk_vhostuser_pvp vIOMMU=no vlan=11 frame=9200
fr9200_fl1024_123_vno_vlan11_result=$(grep -A8 'jq --arg sz 9200 --arg fl 1024' $result_file | grep 'result=' | grep vlan11 | awk -F "," '{print $2}' | awk -F "." '{print $1}')
fr9200_fl1024_143_vno_vlan11_result=$(grep -A8 'jq --arg sz 9200 --arg fl 1024' $result_file | grep 'result=' | grep vlan11 | awk -F "," '{print $4}' | awk -F "." '{print $1}')

# ovs_dpdk_vhostuser_pvp vIOMMU=yes vlan=0 frame=9200
fr9200_fl1024_123_vyes_vlan0_result=$(grep -A8 'jq --arg sz 9200 --arg fl 1024' $result_file | grep 'result=' | grep vlan0 | awk -F "," '{print $6}' | awk -F "." '{print $1}')
fr9200_fl1024_143_vyes_vlan0_result=$(grep -A8 'jq --arg sz 9200 --arg fl 1024' $result_file | grep 'result=' | grep vlan0 | awk -F "," '{print $8}' | awk -F "." '{print $1}')

echo "" | tee -a pass_fail.txt
echo "Test: ovs_dpdk_vhostuser_pvp vIOMMU=no vlan=11 frame=9200 queues=1 pmds=2 vcpus=3" | tee -a pass_fail.txt
get_delta_values $fr9200_fl1024_123_vno_vlan11_result $fr9200_fl1024_123_vno_vlan11_threshold
if [[ $fr9200_fl1024_123_vno_vlan11_result -ge $fr9200_fl1024_123_vno_vlan11_threshold ]]; then echo "Result: PASS Threshold: $fr9200_fl1024_123_vno_vlan11_threshold, Result: $fr9200_fl1024_123_vno_vlan11_result" | tee -a pass_fail.txt; else echo "Result: FAIL Threshold: $fr9200_fl1024_123_vno_vlan11_threshold, Result: $fr9200_fl1024_123_vno_vlan11_result" | tee -a pass_fail.txt; fi
echo "Difference between actual result and threshold: $delta ($pct%)" | tee -a pass_fail.txt

echo "" | tee -a pass_fail.txt
echo "Test: ovs_dpdk_vhostuser_pvp vIOMMU=no vlan=11 frame=9200 queues=1 pmds=4 vcpus=3" | tee -a pass_fail.txt
get_delta_values $fr9200_fl1024_143_vno_vlan11_result $fr9200_fl1024_143_vno_vlan11_threshold
if [[ $fr9200_fl1024_143_vno_vlan11_result -ge $fr9200_fl1024_143_vno_vlan11_threshold ]]; then echo "Result: PASS Threshold: $fr9200_fl1024_143_vno_vlan11_threshold, Result: $fr9200_fl1024_143_vno_vlan11_result" | tee -a pass_fail.txt; else echo "Result: FAIL Threshold: $fr9200_fl1024_143_vno_vlan11_threshold, Result: $fr9200_fl1024_143_vno_vlan11_result" | tee -a pass_fail.txt; fi
echo "Difference between actual result and threshold: $delta ($pct%)" | tee -a pass_fail.txt

echo "" | tee -a pass_fail.txt
echo "Test: ovs_dpdk_vhostuser_pvp vIOMMU=yes vlan=0 frame=9200 queues=1 pmds=2 vcpus=3" | tee -a pass_fail.txt
get_delta_values $fr9200_fl1024_123_vyes_vlan0_result $fr9200_fl1024_123_vyes_vlan0_threshold
if [[ $fr9200_fl1024_123_vyes_vlan0_result -ge $fr9200_fl1024_123_vyes_vlan0_threshold ]]; then echo "Result: PASS Threshold: $fr9200_fl1024_123_vyes_vlan0_threshold, Result: $fr9200_fl1024_123_vyes_vlan0_result" | tee -a pass_fail.txt; else echo "Result: FAIL Threshold: $fr9200_fl1024_123_vyes_vlan0_threshold, Result: $fr9200_fl1024_123_vyes_vlan0_result" | tee -a pass_fail.txt; fi
echo "Difference between actual result and threshold: $delta ($pct%)" | tee -a pass_fail.txt

echo "" | tee -a pass_fail.txt
echo "Test: ovs_dpdk_vhostuser_pvp vIOMMU=yes vlan=0 frame=9200 queues=1 pmds=4 vcpus=3" | tee -a pass_fail.txt
get_delta_values $fr9200_fl1024_143_vyes_vlan0_result $fr9200_fl1024_143_vyes_vlan0_threshold
if [[ $fr9200_fl1024_143_vyes_vlan0_result -ge $fr9200_fl1024_143_vyes_vlan0_threshold ]]; then echo "Result: PASS Threshold: $fr9200_fl1024_143_vyes_vlan0_threshold, Result: $fr9200_fl1024_143_vyes_vlan0_result" | tee -a pass_fail.txt; else echo "Result: FAIL Threshold: $fr9200_fl1024_143_vyes_vlan0_threshold, Result: $fr9200_fl1024_143_vyes_vlan0_result" | tee -a pass_fail.txt; fi
echo "Difference between actual result and threshold: $delta ($pct%)" | tee -a pass_fail.txt


total_tests=$(grep 'Result:' pass_fail.txt | wc -l)
total_failed_tests=$(grep 'Result: FAIL' pass_fail.txt | wc -l)

echo "" | tee -a pass_fail.txt
if [[ $(grep -i fail pass_fail.txt) ]]; then	
	echo "Overall Result: $total_failed_tests of $total_tests tests FAILED"
	echo "" | tee -a pass_fail.txt
	echo "FAILED tests:"
	echo "" | tee -a pass_fail.txt	
	grep -B1 -A1 'Result: FAIL' pass_fail.txt
else
	echo "Overall Result: All tests PASSED"
fi

if [[ $(grep -i fail pass_fail.txt) ]]; then
	echo "" | tee -a pass_fail.txt	
	echo "Overall Result: $total_failed_tests of $total_tests tests FAILED"	
fi

echo "" | tee -a pass_fail.txt
echo "Beaker Job: https://beaker.engineering.redhat.com/jobs/$job_id"
echo "Results: $html_result_file"
echo "" | tee -a pass_fail.txt

popd
