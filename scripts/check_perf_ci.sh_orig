#!/bin/bash

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

# frame size=64, flows=1024, loss-rate=0
frame_size=64
flows=1024
loss_rate=0

echo "Frame size: $frame_size" | tee -a pass_fail.txt
echo "Flows: $flows" | tee -a pass_fail.txt
echo "Loss-rate: $loss_rate" | tee -a pass_fail.txt
echo "" | tee -a pass_fail.txt

fr64_fl1024_123_vno_vlan11_threshold=5700000
fr64_fl1024_143_vno_vlan11_threshold=11000000
fr64_fl1024_245_vno_vlan11_threshold=11000000
fr64_fl1024_489_vno_vlan11_threshold=14000000
fr64_fl1024_123_vyes_vlan0_threshold=6200000
fr64_fl1024_143_vyes_vlan0_threshold=11000000
fr64_fl1024_245_vyes_vlan0_threshold=11000000
fr64_fl1024_489_vyes_vlan0_threshold=14000000
fr64_fl1024_sriov_13_vyes_vlan0_threshold=44000000
fr64_fl1024_testpmd_vno_vlan0_threshold=4000000

# ovs_dpdk_vhostuser
echo "Tests: ovs_dpdk_vhostuser" | tee -a pass_fail.txt
echo "" | tee -a pass_fail.txt

fr64_fl1024_123_vno_vlan11_testname=$(grep -A8 'jq --arg sz 64 --arg fl 1024' $result_file | grep 'result=' | grep vlan11 | awk -F "," '{print $1}' | awk -F '"' '{print $2}')
fr64_fl1024_123_vno_vlan11_result=$(grep -A8 'jq --arg sz 64 --arg fl 1024' $result_file | grep 'result=' | grep vlan11 | awk -F "," '{print $2}' | awk -F "." '{print $1}')

fr64_fl1024_143_vno_vlan11_testname=$(grep -A8 'jq --arg sz 64 --arg fl 1024' $result_file | grep 'result=' | grep vlan11 | awk -F "," '{print $3}' | awk -F '"' '{print $2}')
fr64_fl1024_143_vno_vlan11_result=$(grep -A8 'jq --arg sz 64 --arg fl 1024' $result_file | grep 'result=' | grep vlan11 | awk -F "," '{print $4}' | awk -F "." '{print $1}')

fr64_fl1024_245_vno_vlan11_testname=$(grep -A8 'jq --arg sz 64 --arg fl 1024' $result_file | grep 'result=' | grep vlan11 | awk -F "," '{print $5}' | awk -F '"' '{print $2}')
fr64_fl1024_245_vno_vlan11_result=$(grep -A8 'jq --arg sz 64 --arg fl 1024' $result_file | grep 'result=' | grep vlan11 | awk -F "," '{print $6}' | awk -F "." '{print $1}')

r64_fl1024_489_vno_vlan11_testname=$(grep -A8 'jq --arg sz 64 --arg fl 1024' $result_file | grep 'result=' | grep vlan11 | awk -F "," '{print $7}' | awk -F '"' '{print $2}')
fr64_fl1024_489_vno_vlan11_result=$(grep -A8 'jq --arg sz 64 --arg fl 1024' $result_file | grep 'result=' | grep vlan11 | awk -F "," '{print $8}' | awk -F "." '{print $1}')

fr64_fl1024_123_vyes_vlan0_testname=$(grep -A8 'jq --arg sz 64 --arg fl 1024' $result_file | grep 'result=' | grep vlan0 | awk -F "," '{print $9}' | awk -F '"' '{print $2}')
fr64_fl1024_123_vyes_vlan0_result=$(grep -A8 'jq --arg sz 64 --arg fl 1024' $result_file | grep 'result=' | grep vlan0 | awk -F "," '{print $10}' | awk -F "." '{print $1}')

fr64_fl1024_143_vyes_vlan0_testname=$(grep -A8 'jq --arg sz 64 --arg fl 1024' $result_file | grep 'result=' | grep vlan0 | awk -F "," '{print $11}' | awk -F '"' '{print $2}')
fr64_fl1024_143_vyes_vlan0_result=$(grep -A8 'jq --arg sz 64 --arg fl 1024' $result_file | grep 'result=' | grep vlan0 | awk -F "," '{print $12}' | awk -F "." '{print $1}')

fr64_fl1024_245_vyes_vlan0_testname=$(grep -A8 'jq --arg sz 64 --arg fl 1024' $result_file | grep 'result=' | grep vlan0 | awk -F "," '{print $13}' | awk -F '"' '{print $2}')
fr64_fl1024_245_vyes_vlan0_result=$(grep -A8 'jq --arg sz 64 --arg fl 1024' $result_file | grep 'result=' | grep vlan0 | awk -F "," '{print $14}' | awk -F "." '{print $1}')

fr64_fl1024_489_vyes_vlan0_testname=$(grep -A8 'jq --arg sz 64 --arg fl 1024' $result_file | grep 'result=' | grep vlan0 | awk -F "," '{print $15}' | awk -F '"' '{print $2}')
fr64_fl1024_489_vyes_vlan0_result=$(grep -A8 'jq --arg sz 64 --arg fl 1024' $result_file | grep 'result=' | grep vlan0 | awk -F "," '{print $16}' | awk -F "." '{print $1}')

# sriov
echo "Tests: SR-IOV" | tee -a pass_fail.txt
echo "" | tee -a pass_fail.txt

fr64_fl1024_sriov_13_vyes_vlan0_testname=$(grep -A8 'jq --arg sz 64 --arg fl 1024' $result_file | grep 'result=' | grep vlan0 | awk -F "," '{print $17}' | awk -F '"' '{print $2}')
fr64_fl1024_sriov_13_vyes_vlan0_result=$(grep -A8 'jq --arg sz 64 --arg fl 1024' $result_file | grep 'result=' | grep vlan0 | awk -F "," '{print $18}' | awk -F "." '{print $1}')

# testpmd as switch
echo "Tests: testpmd_as_switch" | tee -a pass_fail.txt
echo "" | tee -a pass_fail.txt

fr64_fl1024_testpmd_vno_vlan0_testname=$(grep -A8 'jq --arg sz 64 --arg fl 1024' $result_file | grep 'result=' | grep vlan0 | awk -F "," '{print $19}' | awk -F '"' '{print $2}')
fr64_fl1024_testpmd_vno_vlan0_result=$(grep -A8 'jq --arg sz 64 --arg fl 1024' $result_file | grep 'result=' | grep vlan0 | awk -F "," '{print $20}' | awk -F "." '{print $1}')

echo "Test: $fr64_fl1024_123_vno_vlan11_testname" | tee -a pass_fail.txt
if [[ $fr64_fl1024_123_vno_vlan11_result -ge $fr64_fl1024_123_vno_vlan11_threshold ]]; then echo "Result: PASS (Threshold: $fr64_fl1024_123_vno_vlan11_threshold, Result: $fr64_fl1024_123_vno_vlan11_result" | tee -a pass_fail.txt; else echo "Result: FAIL (Threshold: $fr64_fl1024_123_vno_vlan11_threshold, Result: $fr64_fl1024_123_vno_vlan11_result" | tee -a pass_fail.txt; fi
echo ""

echo "Test: $fr64_fl1024_143_vno_vlan11_testname" | tee -a pass_fail.txt
if [[ $fr64_fl1024_143_vno_vlan11_result -ge $fr64_fl1024_143_vno_vlan11_threshold ]]; then echo "Result: PASS (Threshold: $fr64_fl1024_143_vno_vlan11_threshold, Result: $fr64_fl1024_143_vno_vlan11_result" | tee -a pass_fail.txt; else echo "Result: FAIL (Threshold: $fr64_fl1024_143_vno_vlan11_threshold, Result: $fr64_fl1024_143_vno_vlan11_result" | tee -a pass_fail.txt; fi
echo ""

echo "Test: $fr64_fl1024_245_vno_vlan11_testname"| tee -a pass_fail.txt
if [[ $fr64_fl1024_245_vno_vlan11_result -ge $fr64_fl1024_245_vno_vlan11_threshold ]]; then echo "Result: PASS (Threshold: $fr64_fl1024_245_vno_vlan11_threshold, Result: $fr64_fl1024_245_vno_vlan11_result" | tee -a pass_fail.txt; else echo "Result: FAIL (Threshold: $fr64_fl1024_245_vno_vlan11_threshold, Result: $fr64_fl1024_245_vno_vlan11_result" | tee -a pass_fail.txt; fi
echo ""

echo "Test: $fr64_fl1024_489_vno_vlan11_testname"| tee -a pass_fail.txt
if [[ $fr64_fl1024_489_vno_vlan11_result -ge $fr64_fl1024_489_vno_vlan11_threshold ]]; then echo "Result: PASS (Threshold: $fr64_fl1024_489_vno_vlan11_threshold, Result: $fr64_fl1024_489_vno_vlan11_result" | tee -a pass_fail.txt | tee -a pass_fail.txt; else echo "Result: FAIL (Threshold: $fr64_fl1024_489_vno_vlan11_threshold, Result: $fr64_fl1024_489_vno_vlan11_result" | tee -a pass_fail.txt; fi
echo ""

echo "Test: $fr64_fl1024_123_vyes_vlan0_testname" | tee -a pass_fail.txt
if [[ $fr64_fl1024_123_vyes_vlan0_result -ge $fr64_fl1024_123_vyes_vlan0_threshold ]]; then echo "Result: PASS (Threshold: $fr64_fl1024_123_vyes_vlan0_threshold, Result: $fr64_fl1024_123_vyes_vlan0_result" | tee -a pass_fail.txt; else echo "Result: FAIL (Threshold: $fr64_fl1024_123_vyes_vlan0_threshold, Result: $fr64_fl1024_123_vyes_vlan0_result" | tee -a pass_fail.txt; fi
echo ""

echo "Test: $fr64_fl1024_143_vyes_vlan0_testname" | tee -a pass_fail.txt
if [[ $fr64_fl1024_143_vyes_vlan0_result -ge $fr64_fl1024_143_vyes_vlan0_threshold ]]; then echo "Result: PASS (Threshold: $fr64_fl1024_143_vyes_vlan0_threshold, Result: $fr64_fl1024_143_vyes_vlan0_result" | tee -a pass_fail.txt; else echo "Result: FAIL (Threshold: $fr64_fl1024_143_vyes_vlan0_threshold, Result: $fr64_fl1024_143_vyes_vlan0_result" | tee -a pass_fail.txt; fi
echo ""

echo "Test: $fr64_fl1024_245_vyes_vlan0_testname" | tee -a pass_fail.txt
if [[ $fr64_fl1024_245_vyes_vlan0_result -ge $fr64_fl1024_245_vyes_vlan0_threshold ]]; then echo "Result: PASS (Threshold: $fr64_fl1024_245_vyes_vlan0_threshold, Result: $fr64_fl1024_245_vyes_vlan0_result" | tee -a pass_fail.txt; else echo "Result: FAIL (Threshold: $fr64_fl1024_245_vyes_vlan0_threshold, Result: $fr64_fl1024_245_vyes_vlan0_result" | tee -a pass_fail.txt; fi
echo ""

echo "Test: $fr64_fl1024_489_vyes_vlan0_testname" | tee -a pass_fail.txt
if [[ $fr64_fl1024_489_vyes_vlan0_result -ge $fr64_fl1024_489_vyes_vlan0_threshold ]]; then echo "Result: PASS (Threshold: $fr64_fl1024_489_vyes_vlan0_threshold, Result: $fr64_fl1024_489_vyes_vlan0_result" | tee -a pass_fail.txt; else echo "Result: FAIL (Threshold: $fr64_fl1024_489_vyes_vlan0_threshold, Result: $fr64_fl1024_489_vyes_vlan0_result" | tee -a pass_fail.txt; fi
echo ""

echo "Test: $fr64_fl1024_sriov_13_vyes_vlan0_testname" | tee -a pass_fail.txt
if [[ $fr64_fl1024_sriov_13_vyes_vlan0_result -ge $fr64_fl1024_sriov_13_vyes_vlan0_threshold ]]; then echo "Result: PASS (Threshold: $fr64_fl1024_sriov_13_vyes_vlan0_threshold, Result: $fr64_fl1024_sriov_13_vyes_vlan0_result" | tee -a pass_fail.txt; else echo "Result: FAIL (Threshold: $fr64_fl1024_sriov_13_vyes_vlan0_threshold, Result: $fr64_fl1024_sriov_13_vyes_vlan0_result" | tee -a pass_fail.txt; fi
echo ""

echo "Test: $fr64_fl1024_testpmd_vno_vlan0_testname" | tee -a pass_fail.txt
if [[ $fr64_fl1024_testpmd_vno_vlan0_result -ge $fr64_fl1024_testpmd_vno_vlan0_threshold ]]; then echo "Result: PASS (Threshold: $fr64_fl1024_testpmd_vno_vlan0_threshold, Result: $fr64_fl1024_testpmd_vno_vlan0_result" | tee -a pass_fail.txt; else echo "Result: FAIL (Threshold: $fr64_fl1024_testpmd_vno_vlan0_threshold, Result: $fr64_fl1024_testpmd_vno_vlan0_result" | tee -a pass_fail.txt; fi
echo ""

# frame size=64, flows=1024 ovs_kernel, loss-rate=0.002
frame_size=64
flows=1024
loss_rate=0.002

echo "Tests: kernel_pvp" | tee -a pass_fail.txt
echo "" | tee -a pass_fail.txt

fr64_fl1024_kernel_13_vno_vlan0_threshold=500000

fr64_fl1024_kernel_13_vno_vlan0_result=$(grep -A8 'jq --arg sz 64 --arg fl 1024' $result_file | grep 'result=' | grep vlan0 | awk -F "," '{print $2}' | awk -F "." '{print $1}' | tail -n1)

echo "Test: fr64_fl1024_kernel_13_vno_vlan0" | tee -a pass_fail.txt
if [[ $fr64_fl1024_kernel_13_vno_vlan0_result -ge $fr64_fl1024_kernel_13_vno_vlan0_threshold ]]; then echo "Result: PASS (Threshold: $fr64_fl1024_kernel_13_vno_vlan0_threshold, Result: $fr64_fl1024_kernel_13_vno_vlan0_result" | tee -a pass_fail.txt; else echo "Result: FAIL (Threshold: $fr64_fl1024_kernel_13_vno_vlan0_threshold, Result: $fr64_fl1024_kernel_13_vno_vlan0_result" | tee -a pass_fail.txt; fi
echo ""

# frame size=128, flows=1024, loss-rate=0

fr128_fl1024_123_vno_vlan11_threshold=5400000
fr128_fl1024_143_vno_vlan11_threshold=9100000
fr128_fl1024_245_vno_vlan11_threshold=9800000
fr128_fl1024_489_vno_vlan11_threshold=1300000
fr128_fl1024_123_vyes_vlan0_threshold=5700000
fr128_fl1024_143_vyes_vlan0_threshold=9000000
fr128_fl1024_245_vyes_vlan0_threshold=1000000
fr128_fl1024_489_vyes_vlan0_threshold=1300000

# ovs_dpdk_vhostuser
fr128_fl1024_123_vno_vlan11_result=$(grep -A8 'jq --arg sz 128 --arg fl 1024' $result_file | grep 'result=' | grep vlan11 | awk -F "," '{print $2}' | awk -F "." '{print $1}')
fr128_fl1024_143_vno_vlan11_result=$(grep -A8 'jq --arg sz 128 --arg fl 1024' $result_file | grep 'result=' | grep vlan11 | awk -F "," '{print $4}' | awk -F "." '{print $1}')
fr128_fl1024_245_vno_vlan11_result=$(grep -A8 'jq --arg sz 128 --arg fl 1024' $result_file | grep 'result=' | grep vlan11 | awk -F "," '{print $6}' | awk -F "." '{print $1}')
fr128_fl1024_489_vno_vlan11_result=$(grep -A8 'jq --arg sz 128 --arg fl 1024' $result_file | grep 'result=' | grep vlan11 | awk -F "," '{print $8}' | awk -F "." '{print $1}')
fr128_fl1024_123_vyes_vlan0_result=$(grep -A8 'jq --arg sz 128 --arg fl 1024' $result_file | grep 'result=' | grep vlan0 | awk -F "," '{print $10}' | awk -F "." '{print $1}')
fr128_fl1024_143_vyes_vlan0_result=$(grep -A8 'jq --arg sz 128 --arg fl 1024' $result_file | grep 'result=' | grep vlan0 | awk -F "," '{print $12}' | awk -F "." '{print $1}')
fr128_fl1024_245_vyes_vlan0_result=$(grep -A8 'jq --arg sz 128 --arg fl 1024' $result_file | grep 'result=' | grep vlan0 | awk -F "," '{print $14}' | awk -F "." '{print $1}')
fr128_fl1024_489_vyes_vlan0_result=$(grep -A8 'jq --arg sz 128 --arg fl 1024' $result_file | grep 'result=' | grep vlan0 | awk -F "," '{print $16}' | awk -F "." '{print $1}')

echo "Test: fr128_fl1024_123_vno_vlan11" | tee -a pass_fail.txt
if [[ $fr128_fl1024_123_vno_vlan11_result -ge $fr128_fl1024_123_vno_vlan11_threshold ]]; then echo "Result: PASS (Threshold: $fr128_fl1024_123_vno_vlan11_threshold, Result: $fr128_fl1024_123_vno_vlan11_result" | tee -a pass_fail.txt; else echo "Result: FAIL (Threshold: $fr128_fl1024_123_vno_vlan11_threshold, Result: $fr128_fl1024_123_vno_vlan11_result" | tee -a pass_fail.txt; fi
echo ""

echo "Test: fr128_fl1024_143_vno_vlan11" | tee -a pass_fail.txt
if [[ $fr128_fl1024_143_vno_vlan11_result -ge $fr128_fl1024_143_vno_vlan11_threshold ]]; then echo "Result: PASS (Threshold: $fr128_fl1024_143_vno_vlan11_threshold, Result: $fr128_fl1024_143_vno_vlan11_result" | tee -a pass_fail.txt; else echo "Result: FAIL (Threshold: $fr128_fl1024_143_vno_vlan11_threshold, Result: $fr128_fl1024_143_vno_vlan11_result" | tee -a pass_fail.txt; fi
echo ""

echo "Test: fr128_fl1024_245_vno_vlan11" | tee -a pass_fail.txt
if [[ $fr128_fl1024_245_vno_vlan11_result -ge $fr128_fl1024_245_vno_vlan11_threshold ]]; then echo "Result: PASS (Threshold: $fr128_fl1024_245_vno_vlan11_threshold, Result: $fr128_fl1024_245_vno_vlan11_result" | tee -a pass_fail.txt; else echo "Result: FAIL (Threshold: $fr128_fl1024_245_vno_vlan11_threshold, Result: $fr128_fl1024_245_vno_vlan11_result" | tee -a pass_fail.txt; fi
echo ""

echo "Test: fr128_fl1024_489_vno_vlan11" | tee -a pass_fail.txt
if [[ $fr128_fl1024_489_vno_vlan11_result -ge $fr128_fl1024_489_vno_vlan11_threshold ]]; then echo "Result: PASS (Threshold: $fr128_fl1024_489_vno_vlan11_threshold, Result: $fr128_fl1024_489_vno_vlan11_result" | tee -a pass_fail.txt; else echo "Result: FAIL (Threshold: $fr128_fl1024_489_vno_vlan11_threshold, Result: $fr128_fl1024_489_vno_vlan11_result" | tee -a pass_fail.txt; fi
echo ""

echo "Test: fr128_fl1024_123_vyes_vlan0" | tee -a pass_fail.txt
if [[ $fr128_fl1024_123_vyes_vlan0_result -ge $fr128_fl1024_123_vyes_vlan0_threshold ]]; then echo "Result: PASS (Threshold: $fr128_fl1024_123_vyes_vlan0_threshold, Result: $fr128_fl1024_123_vyes_vlan0_result" | tee -a pass_fail.txt; else echo "Result: FAIL (Threshold: $fr128_fl1024_123_vyes_vlan0_threshold, Result: $fr128_fl1024_123_vyes_vlan0_result" | tee -a pass_fail.txt; fi
echo ""

echo "Test: fr128_fl1024_143_vyes_vlan0" | tee -a pass_fail.txt
if [[ $fr128_fl1024_143_vyes_vlan0_result -ge $fr128_fl1024_143_vyes_vlan0_threshold ]]; then echo "Result: PASS (Threshold: $fr128_fl1024_143_vyes_vlan0_threshold, Result: $fr128_fl1024_143_vyes_vlan0_result" | tee -a pass_fail.txt; else echo "Result: FAIL (Threshold: $fr128_fl1024_143_vyes_vlan0_threshold, Result: $fr128_fl1024_143_vyes_vlan0_result" | tee -a pass_fail.txt; fi
echo ""

echo "Test: fr128_fl1024_245_vyes_vlan0" | tee -a pass_fail.txt
if [[ $fr128_fl1024_245_vyes_vlan0_result -ge $fr128_fl1024_245_vyes_vlan0_threshold ]]; then echo "Result: PASS (Threshold: $fr128_fl1024_245_vyes_vlan0_threshold, Result: $fr128_fl1024_245_vyes_vlan0_result" | tee -a pass_fail.txt; else echo "Result: FAIL (Threshold: $fr128_fl1024_245_vyes_vlan0_threshold, Result: $fr128_fl1024_245_vyes_vlan0_result" | tee -a pass_fail.txt; fi
echo ""

echo "Test: fr128_fl1024_489_vyes_vlan0" | tee -a pass_fail.txt
if [[ $fr128_fl1024_489_vyes_vlan0_result -ge $fr128_fl1024_489_vyes_vlan0_threshold ]]; then echo "Result: PASS (Threshold: $fr128_fl1024_489_vyes_vlan0_threshold, Result: $fr128_fl1024_489_vyes_vlan0_result" | tee -a pass_fail.txt; else echo "Result: FAIL (Threshold: $fr128_fl1024_489_vyes_vlan0_threshold, Result: $fr128_fl1024_489_vyes_vlan0_result" | tee -a pass_fail.txt; fi
echo ""

# frame size=256, flows=1024, loss-rate=0

fr256_fl1024_123_vno_vlan11_threshold=5000000
fr256_fl1024_143_vno_vlan11_threshold=8500000
fr256_fl1024_245_vno_vlan11_threshold=9200000
fr256_fl1024_489_vno_vlan11_threshold=12000000
fr256_fl1024_123_vyes_vlan0_threshold=5400000
fr256_fl1024_143_vyes_vlan0_threshold=8400000
fr256_fl1024_245_vyes_vlan0_threshold=9500000
fr256_fl1024_489_vyes_vlan0_threshold=12000000

fr256_fl1024_123_vno_vlan11_result=$(grep -A8 'jq --arg sz 256 --arg fl 1024' $result_file | grep 'result=' | grep vlan11 | awk -F "," '{print $2}' | awk -F "." '{print $1}')
fr256_fl1024_143_vno_vlan11_result=$(grep -A8 'jq --arg sz 256 --arg fl 1024' $result_file | grep 'result=' | grep vlan11 | awk -F "," '{print $4}' | awk -F "." '{print $1}')
fr256_fl1024_245_vno_vlan11_result=$(grep -A8 'jq --arg sz 256 --arg fl 1024' $result_file | grep 'result=' | grep vlan11 | awk -F "," '{print $6}' | awk -F "." '{print $1}')
fr256_fl1024_489_vno_vlan11_result=$(grep -A8 'jq --arg sz 256 --arg fl 1024' $result_file | grep 'result=' | grep vlan11 | awk -F "," '{print $8}' | awk -F "." '{print $1}')
fr256_fl1024_123_vyes_vlan0_result=$(grep -A8 'jq --arg sz 256 --arg fl 1024' $result_file | grep 'result=' | grep vlan0 | awk -F "," '{print $10}' | awk -F "." '{print $1}')
fr256_fl1024_143_vyes_vlan0_result=$(grep -A8 'jq --arg sz 256 --arg fl 1024' $result_file | grep 'result=' | grep vlan0 | awk -F "," '{print $12}' | awk -F "." '{print $1}')
fr256_fl1024_245_vyes_vlan0_result=$(grep -A8 'jq --arg sz 256 --arg fl 1024' $result_file | grep 'result=' | grep vlan0 | awk -F "," '{print $14}' | awk -F "." '{print $1}')
fr256_fl1024_489_vyes_vlan0_result=$(grep -A8 'jq --arg sz 256 --arg fl 1024' $result_file | grep 'result=' | grep vlan0 | awk -F "," '{print $16}' | awk -F "." '{print $1}')

echo "Test: fr256_fl1024_123_vno_vlan11" | tee -a pass_fail.txt
if [[ $fr256_fl1024_123_vno_vlan11_result -ge $fr256_fl1024_123_vno_vlan11_threshold ]]; then echo "Result: PASS (Threshold: $fr256_fl1024_123_vno_vlan11_threshold, Result: $fr256_fl1024_123_vno_vlan11_result" | tee -a pass_fail.txt; else echo "Result: FAIL (Threshold: $fr256_fl1024_123_vno_vlan11_threshold, Result: $fr256_fl1024_123_vno_vlan11_result" | tee -a pass_fail.txt; fi
echo ""

echo "Test: fr256_fl1024_143_vno_vlan11" | tee -a pass_fail.txt
if [[ $fr256_fl1024_143_vno_vlan11_result -ge $fr256_fl1024_143_vno_vlan11_threshold ]]; then echo "Result: PASS (Threshold: $fr256_fl1024_143_vno_vlan11_threshold, Result: $fr256_fl1024_143_vno_vlan11_result" | tee -a pass_fail.txt; else echo "Result: FAIL (Threshold: $fr256_fl1024_143_vno_vlan11_threshold, Result: $fr256_fl1024_143_vno_vlan11_result" | tee -a pass_fail.txt; fi
echo ""

echo "Test: fr256_fl1024_245_vno_vlan11" | tee -a pass_fail.txt
if [[ $fr256_fl1024_245_vno_vlan11_result -ge $fr256_fl1024_245_vno_vlan11_threshold ]]; then echo "Result: PASS (Threshold: $fr256_fl1024_245_vno_vlan11_threshold, Result: $fr256_fl1024_245_vno_vlan11_result" | tee -a pass_fail.txt; else echo "Result: FAIL (Threshold: $fr256_fl1024_245_vno_vlan11_threshold, Result: $fr256_fl1024_245_vno_vlan11_result" | tee -a pass_fail.txt; fi
echo ""

echo "Test: fr256_fl1024_489_vno_vlan11" | tee -a pass_fail.txt
if [[ $fr256_fl1024_489_vno_vlan11_result -ge $fr256_fl1024_489_vno_vlan11_threshold ]]; then echo "Result: PASS (Threshold: $fr256_fl1024_489_vno_vlan11_threshold, Result: $fr256_fl1024_489_vno_vlan11_result" | tee -a pass_fail.txt; else echo "Result: FAIL (Threshold: $fr256_fl1024_489_vno_vlan11_threshold, Result: $fr256_fl1024_489_vno_vlan11_result" | tee -a pass_fail.txt; fi
echo ""

echo "Test: fr256_fl1024_123_vyes_vlan0" | tee -a pass_fail.txt
if [[ $fr256_fl1024_123_vyes_vlan0_result -ge $fr256_fl1024_123_vyes_vlan0_threshold ]]; then echo "Result: PASS (Threshold: $fr256_fl1024_123_vyes_vlan0_threshold, Result: $fr256_fl1024_123_vyes_vlan0_result" | tee -a pass_fail.txt; else echo "Result: FAIL (Threshold: $fr256_fl1024_123_vyes_vlan0_threshold, Result: $fr256_fl1024_123_vyes_vlan0_result" | tee -a pass_fail.txt; fi
echo ""

echo "Test: fr256_fl1024_143_vyes_vlan0" | tee -a pass_fail.txt
if [[ $fr256_fl1024_143_vyes_vlan0_result -ge $fr256_fl1024_143_vyes_vlan0_threshold ]]; then echo "Result: PASS (Threshold: $fr256_fl1024_143_vyes_vlan0_threshold, Result: $fr256_fl1024_143_vyes_vlan0_result" | tee -a pass_fail.txt; else echo "Result: FAIL (Threshold: $fr256_fl1024_143_vyes_vlan0_threshold, Result: $fr256_fl1024_143_vyes_vlan0_result" | tee -a pass_fail.txt; fi
echo ""

echo "Test: fr256_fl1024_245_vyes_vlan0" | tee -a pass_fail.txt
if [[ $fr256_fl1024_245_vyes_vlan0_result -ge $fr256_fl1024_245_vyes_vlan0_threshold ]]; then echo "Result: PASS (Threshold: $fr256_fl1024_245_vyes_vlan0_threshold, Result: $fr256_fl1024_245_vyes_vlan0_result" | tee -a pass_fail.txt; else echo "Result: FAIL (Threshold: $fr256_fl1024_245_vyes_vlan0_threshold, Result: $fr256_fl1024_245_vyes_vlan0_result" | tee -a pass_fail.txt; fi
echo ""

echo "Test: fr256_fl1024_489_vyes_vlan0" | tee -a pass_fail.txt
if [[ $fr256_fl1024_489_vyes_vlan0_result -ge $fr256_fl1024_489_vyes_vlan0_threshold ]]; then echo "Result: PASS (Threshold: $fr256_fl1024_489_vyes_vlan0_threshold, Result: $fr256_fl1024_489_vyes_vlan0_result" | tee -a pass_fail.txt; else echo "Result: FAIL (Threshold: $fr256_fl1024_489_vyes_vlan0_threshold, Result: $fr256_fl1024_489_vyes_vlan0_result" | tee -a pass_fail.txt; fi
echo ""

# frame size=1500, flows=1024, loss-rate=0

fr1500_fl1024_123_vno_vlan11_threshold=2200000
fr1500_fl1024_143_vno_vlan11_threshold=2600000
fr1500_fl1024_245_vno_vlan11_threshold=3100000
fr1500_fl1024_489_vno_vlan11_threshold=3600000
fr1500_fl1024_123_vyes_vlan0_threshold=3300000
fr1500_fl1024_143_vyes_vlan0_threshold=4600000
fr1500_fl1024_245_vyes_vlan0_threshold=4600000
fr1500_fl1024_489_vyes_vlan0_threshold=4500000

fr1500_fl1024_123_vno_vlan11_result=$(grep -A8 'jq --arg sz 1500 --arg fl 1024' $result_file | grep 'result=' | grep vlan11 | awk -F "," '{print $2}' | awk -F "." '{print $1}')
fr1500_fl1024_143_vno_vlan11_result=$(grep -A8 'jq --arg sz 1500 --arg fl 1024' $result_file | grep 'result=' | grep vlan11 | awk -F "," '{print $4}' | awk -F "." '{print $1}')
fr1500_fl1024_245_vno_vlan11_result=$(grep -A8 'jq --arg sz 1500 --arg fl 1024' $result_file | grep 'result=' | grep vlan11 | awk -F "," '{print $6}' | awk -F "." '{print $1}')
fr1500_fl1024_489_vno_vlan11_result=$(grep -A8 'jq --arg sz 1500 --arg fl 1024' $result_file | grep 'result=' | grep vlan11 | awk -F "," '{print $8}' | awk -F "." '{print $1}')
fr1500_fl1024_123_vyes_vlan0_result=$(grep -A8 'jq --arg sz 1500 --arg fl 1024' $result_file | grep 'result=' | grep vlan0 | awk -F "," '{print $10}' | awk -F "." '{print $1}')
fr1500_fl1024_143_vyes_vlan0_result=$(grep -A8 'jq --arg sz 1500 --arg fl 1024' $result_file | grep 'result=' | grep vlan0 | awk -F "," '{print $12}' | awk -F "." '{print $1}')
fr1500_fl1024_245_vyes_vlan0_result=$(grep -A8 'jq --arg sz 1500 --arg fl 1024' $result_file | grep 'result=' | grep vlan0 | awk -F "," '{print $14}' | awk -F "." '{print $1}')
fr1500_fl1024_489_vyes_vlan0_result=$(grep -A8 'jq --arg sz 1500 --arg fl 1024' $result_file | grep 'result=' | grep vlan0 | awk -F "," '{print $16}' | awk -F "." '{print $1}')

echo "Test: fr1500_fl1024_123_vno_vlan11" | tee -a pass_fail.txt
if [[ $fr1500_fl1024_123_vno_vlan11_result -ge $fr1500_fl1024_123_vno_vlan11_threshold ]]; then echo "Result: PASS (Threshold: $fr1500_fl1024_123_vno_vlan11_threshold, Result: $fr1500_fl1024_123_vno_vlan11_result" | tee -a pass_fail.txt; else echo "Result: FAIL (Threshold: $fr1500_fl1024_123_vno_vlan11_threshold, Result: $fr1500_fl1024_123_vno_vlan11_result" | tee -a pass_fail.txt; fi
echo ""

echo "Test: fr1500_fl1024_143_vno_vlan11" | tee -a pass_fail.txt
if [[ $fr1500_fl1024_143_vno_vlan11_result -ge $fr1500_fl1024_143_vno_vlan11_threshold ]]; then echo "Result: PASS (Threshold: $fr1500_fl1024_143_vno_vlan11_threshold, Result: $fr1500_fl1024_143_vno_vlan11_result" | tee -a pass_fail.txt; else echo "Result: FAIL (Threshold: $fr1500_fl1024_143_vno_vlan11_threshold, Result: $fr1500_fl1024_143_vno_vlan11_result" | tee -a pass_fail.txt; fi
echo ""

echo "Test: fr1500_fl1024_245_vno_vlan11" | tee -a pass_fail.txt
if [[ $fr1500_fl1024_245_vno_vlan11_result -ge $fr1500_fl1024_245_vno_vlan11_threshold ]]; then echo "Result: PASS (Threshold: $fr1500_fl1024_245_vno_vlan11_threshold, Result: $fr1500_fl1024_245_vno_vlan11_result" | tee -a pass_fail.txt; else echo "Result: FAIL (Threshold: $fr1500_fl1024_245_vno_vlan11_threshold, Result: $fr1500_fl1024_245_vno_vlan11_result" | tee -a pass_fail.txt; fi
echo ""

echo "Test: fr1500_fl1024_489_vno_vlan11" | tee -a pass_fail.txt
if [[ $fr1500_fl1024_489_vno_vlan11_result -ge $fr1500_fl1024_489_vno_vlan11_threshold ]]; then echo "Result: PASS (Threshold: $fr1500_fl1024_489_vno_vlan11_threshold, Result: $fr1500_fl1024_489_vno_vlan11_result" | tee -a pass_fail.txt; else echo "Result: FAIL (Threshold: $fr1500_fl1024_489_vno_vlan11_threshold, Result: $fr1500_fl1024_489_vno_vlan11_result" | tee -a pass_fail.txt; fi
echo ""

echo "Test: fr1500_fl1024_123_vyes_vlan0" | tee -a pass_fail.txt
if [[ $fr1500_fl1024_123_vyes_vlan0_result -ge $fr1500_fl1024_123_vyes_vlan0_threshold ]]; then echo "Result: PASS (Threshold: $fr1500_fl1024_123_vyes_vlan0_threshold, Result: $fr1500_fl1024_123_vyes_vlan0_result" | tee -a pass_fail.txt; else echo "Result: FAIL (Threshold: $fr1500_fl1024_123_vyes_vlan0_threshold, Result: $fr1500_fl1024_123_vyes_vlan0_result" | tee -a pass_fail.txt; fi
echo ""

echo "Test: fr1500_fl1024_143_vyes_vlan0" | tee -a pass_fail.txt
if [[ $fr1500_fl1024_143_vyes_vlan0_result -ge $fr1500_fl1024_143_vyes_vlan0_threshold ]]; then echo "Result: PASS (Threshold: $fr1500_fl1024_143_vyes_vlan0_threshold, Result: $fr1500_fl1024_143_vyes_vlan0_result" | tee -a pass_fail.txt; else echo "Result: FAIL (Threshold: $fr1500_fl1024_143_vyes_vlan0_threshold, Result: $fr1500_fl1024_143_vyes_vlan0_result" | tee -a pass_fail.txt; fi
echo ""

echo "Test: fr1500_fl1024_245_vyes_vlan0" | tee -a pass_fail.txt
if [[ $fr1500_fl1024_245_vyes_vlan0_result -ge $fr1500_fl1024_245_vyes_vlan0_threshold ]]; then echo "Result: PASS (Threshold: $fr1500_fl1024_245_vyes_vlan0_threshold, Result: $fr1500_fl1024_245_vyes_vlan0_result" | tee -a pass_fail.txt; else echo "Result: FAIL (Threshold: $fr1500_fl1024_245_vyes_vlan0_threshold, Result: $fr1500_fl1024_245_vyes_vlan0_result" | tee -a pass_fail.txt; fi
echo ""

echo "Test: fr1500_fl1024_489_vyes_vlan0" | tee -a pass_fail.txt
if [[ $fr1500_fl1024_489_vyes_vlan0_result -ge $fr1500_fl1024_489_vyes_vlan0_threshold ]]; then echo "Result: PASS (Threshold: $fr1500_fl1024_489_vyes_vlan0_threshold, Result: $fr1500_fl1024_489_vyes_vlan0_result" | tee -a pass_fail.txt; else echo "Result: FAIL (Threshold: $fr1500_fl1024_489_vyes_vlan0_threshold, Result: $fr1500_fl1024_489_vyes_vlan0_result" | tee -a pass_fail.txt; fi
echo ""

# sriov

fr1500_fl1024_sriov_13_vyes_vlan0_threshold=8000000
fr1500_fl1024_sriov_13_vyes_vlan0_result=$(grep -A8 'jq --arg sz 1500 --arg fl 1024' $result_file | grep 'result=' | grep vlan0 | awk -F "," '{print $18}' | awk -F "." '{print $1}')

echo "Test: fr1500_fl1024_sriov_13_vyes_vlan0" | tee -a pass_fail.txt
if [[ $fr1500_fl1024_sriov_13_vyes_vlan0_result -ge $fr1500_fl1024_sriov_13_vyes_vlan0_threshold ]]; then echo "Result: PASS (Threshold: $fr1500_fl1024_sriov_13_vyes_vlan0_threshold, Result: $fr1500_fl1024_sriov_13_vyes_vlan0_result" | tee -a pass_fail.txt; else echo "Result: FAIL (Threshold: $fr1500_fl1024_sriov_13_vyes_vlan0_threshold, Result: $fr1500_fl1024_sriov_13_vyes_vlan0_result" | tee -a pass_fail.txt; fi
echo ""

# frame size=2000, flows=1024, loss-rate=0

fr2000_fl1024_123_vno_vlan11_threshold=1800000
fr2000_fl1024_143_vno_vlan11_threshold=2300000
fr2000_fl1024_123_vyes_vlan0_threshold=2600000
fr2000_fl1024_143_vyes_vlan0_threshold=4000000

fr2000_fl1024_123_vno_vlan11_result=$(grep -A8 'jq --arg sz 2000 --arg fl 1024' $result_file | grep 'result=' | grep vlan11 | awk -F "," '{print $2}' | awk -F "." '{print $1}')
fr2000_fl1024_143_vno_vlan11_result=$(grep -A8 'jq --arg sz 2000 --arg fl 1024' $result_file | grep 'result=' | grep vlan11 | awk -F "," '{print $4}' | awk -F "." '{print $1}')
fr2000_fl1024_123_vyes_vlan0_result=$(grep -A8 'jq --arg sz 2000 --arg fl 1024' $result_file | grep 'result=' | grep vlan0 | awk -F "," '{print $6}' | awk -F "." '{print $1}')
fr2000_fl1024_143_vyes_vlan0_result=$(grep -A8 'jq --arg sz 2000 --arg fl 1024' $result_file | grep 'result=' | grep vlan0 | awk -F "," '{print $8}' | awk -F "." '{print $1}')

echo "Test: fr2000_fl1024_123_vno_vlan11" | tee -a pass_fail.txt
if [[ $fr2000_fl1024_123_vno_vlan11_result -ge $fr2000_fl1024_123_vno_vlan11_threshold ]]; then echo "Result: PASS (Threshold: $fr2000_fl1024_123_vno_vlan11_threshold, Result: $fr2000_fl1024_123_vno_vlan11_result" | tee -a pass_fail.txt; else echo "Result: FAIL (Threshold: $fr2000_fl1024_123_vno_vlan11_threshold, Result: $fr2000_fl1024_123_vno_vlan11_result" | tee -a pass_fail.txt; fi
echo ""

echo "Test: fr2000_fl1024_143_vno_vlan11" | tee -a pass_fail.txt
if [[ $fr2000_fl1024_143_vno_vlan11_result -ge $fr2000_fl1024_143_vno_vlan11_threshold ]]; then echo "Result: PASS (Threshold: $fr2000_fl1024_143_vno_vlan11_threshold, Result: $fr2000_fl1024_143_vno_vlan11_result" | tee -a pass_fail.txt; else echo "Result: FAIL (Threshold: $fr2000_fl1024_143_vno_vlan11_threshold, Result: $fr2000_fl1024_143_vno_vlan11_result" | tee -a pass_fail.txt; fi
echo ""

echo "Test: fr2000_fl1024_123_vyes_vlan0" | tee -a pass_fail.txt
if [[ $fr2000_fl1024_123_vyes_vlan0_result -ge $fr2000_fl1024_123_vyes_vlan0_threshold ]]; then echo "Result: PASS (Threshold: $fr2000_fl1024_123_vyes_vlan0_threshold, Result: $fr2000_fl1024_123_vyes_vlan0_result" | tee -a pass_fail.txt; else echo "Result: FAIL (Threshold: $fr2000_fl1024_123_vyes_vlan0_threshold, Result: $fr2000_fl1024_123_vyes_vlan0_result" | tee -a pass_fail.txt; fi
echo ""

echo "Test: fr2000_fl1024_143_vyes_vlan0" | tee -a pass_fail.txt
if [[ $fr2000_fl1024_143_vyes_vlan0_result -ge $fr2000_fl1024_143_vyes_vlan0_threshold ]]; then echo "Result: PASS (Threshold: $fr2000_fl1024_143_vyes_vlan0_threshold, Result: $fr2000_fl1024_143_vyes_vlan0_result" | tee -a pass_fail.txt; else echo "Result: FAIL (Threshold: $fr2000_fl1024_143_vyes_vlan0_threshold, Result: $fr2000_fl1024_143_vyes_vlan0_result" | tee -a pass_fail.txt; fi
echo ""

# frame size=9200, flows=1024, loss-rate=0

fr9200_fl1024_123_vno_vlan11_threshold=500000
fr9200_fl1024_143_vno_vlan11_threshold=700000
fr9200_fl1024_123_vyes_vlan0_threshold=600000
fr9200_fl1024_143_vyes_vlan0_threshold=800000

fr9200_fl1024_123_vno_vlan11_result=$(grep -A8 'jq --arg sz 9200 --arg fl 1024' $result_file | grep 'result=' | grep vlan11 | awk -F "," '{print $2}' | awk -F "." '{print $1}')
fr9200_fl1024_143_vno_vlan11_result=$(grep -A8 'jq --arg sz 9200 --arg fl 1024' $result_file | grep 'result=' | grep vlan11 | awk -F "," '{print $4}' | awk -F "." '{print $1}')
fr9200_fl1024_123_vyes_vlan0_result=$(grep -A8 'jq --arg sz 9200 --arg fl 1024' $result_file | grep 'result=' | grep vlan0 | awk -F "," '{print $6}' | awk -F "." '{print $1}')
fr9200_fl1024_143_vyes_vlan0_result=$(grep -A8 'jq --arg sz 9200 --arg fl 1024' $result_file | grep 'result=' | grep vlan0 | awk -F "," '{print $8}' | awk -F "." '{print $1}')

echo "Test: fr9200_fl1024_123_vno_vlan11" | tee -a pass_fail.txt
if [[ $fr9200_fl1024_123_vno_vlan11_result -ge $fr9200_fl1024_123_vno_vlan11_threshold ]]; then echo "Result: PASS (Threshold: $fr9200_fl1024_123_vno_vlan11_threshold, Result: $fr9200_fl1024_123_vno_vlan11_result" | tee -a pass_fail.txt; else echo "Result: FAIL (Threshold: $fr9200_fl1024_123_vno_vlan11_threshold, Result: $fr9200_fl1024_123_vno_vlan11_result" | tee -a pass_fail.txt; fi
echo ""

echo "Test: fr9200_fl1024_143_vno_vlan11" | tee -a pass_fail.txt
if [[ $fr9200_fl1024_143_vno_vlan11_result -ge $fr9200_fl1024_143_vno_vlan11_threshold ]]; then echo "Result: PASS (Threshold: $fr9200_fl1024_143_vno_vlan11_threshold, Result: $fr9200_fl1024_143_vno_vlan11_result" | tee -a pass_fail.txt; else echo "Result: FAIL (Threshold: $fr9200_fl1024_143_vno_vlan11_threshold, Result: $fr9200_fl1024_143_vno_vlan11_result" | tee -a pass_fail.txt; fi
echo ""

echo "Test: fr9200_fl1024_123_vyes_vlan0" | tee -a pass_fail.txt
if [[ $fr9200_fl1024_123_vyes_vlan0_result -ge $fr9200_fl1024_123_vyes_vlan0_threshold ]]; then echo "Result: PASS (Threshold: $fr9200_fl1024_123_vyes_vlan0_threshold, Result: $fr9200_fl1024_123_vyes_vlan0_result" | tee -a pass_fail.txt; else echo "Result: FAIL (Threshold: $fr9200_fl1024_123_vyes_vlan0_threshold, Result: $fr9200_fl1024_123_vyes_vlan0_result" | tee -a pass_fail.txt; fi
echo ""

echo "Test: fr9200_fl1024_143_vyes_vlan0" | tee -a pass_fail.txt
if [[ $fr9200_fl1024_143_vyes_vlan0_result -ge $fr9200_fl1024_143_vyes_vlan0_threshold ]]; then echo "Result: PASS (Threshold: $fr9200_fl1024_143_vyes_vlan0_threshold, Result: $fr9200_fl1024_143_vyes_vlan0_result" | tee -a pass_fail.txt; else echo "Result: FAIL (Threshold: $fr9200_fl1024_143_vyes_vlan0_threshold, Result: $fr9200_fl1024_143_vyes_vlan0_result" | tee -a pass_fail.txt; fi
echo ""

total_tests=$(grep 'Result:' pass_fail.txt | wc -l)
total_failed_tests=$(grep 'Result: FAIL' pass_fail.txt | wc -l)
if [[ $(grep -i fail pass_fail.txt) ]]; then
	echo ""
	echo "Overall Result: $total_failed_tests of $total_tests tests FAILED"
	echo "FAILED tests:"
	grep -B1 'Result: FAIL' pass_fail.txt
else
	echo "Overall Result: All tests PASSED"
fi
echo ""

if [[ $(grep -i fail pass_fail.txt) ]]; then
	echo ""
	echo "Overall Result: $total_failed_tests of $total_tests tests FAILED"
	echo ""
fi

echo "Result file: $html_result_file"
echo ""

popd

