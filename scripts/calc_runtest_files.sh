#!/bin/bash

echo "This script will determine how many total runtest.sh files exist under the kernel/networking/openvswitch directory"
echo "It will then determine how many of those runtest.sh files have been authored by Rick Alongi."
echo "A basic statistical summary is provided as well as a list of the associated runtest.sh files."
echo "This exercise is in no way trying to make a statement about workload distribution.  It is simply a snapshot of who created these particular tests."
echo -e "\n"

rm -f /tmp/runtest_list.txt
rm -f /tmp/rick_tests.txt
rm -f /tmp/rick_test_list

find /home/ralongi/kernel/networking/openvswitch -name runtest.sh > /tmp/runtest_list.txt
total_ovs_tests=$(cat /tmp/runtest_list.txt | wc -l)
for i in $(cat /tmp/runtest_list.txt); do
	grep -i alongi $i >> /tmp/rick_tests.txt
	if [[ $? -eq 0 ]]; then
		echo $i >> /tmp/rick_test_list
	fi
done
		
total_rick_tests=$(cat /tmp/rick_tests.txt | wc -l)

echo "Total OVS tests (runtest.sh files) existing under kernel/networking/openvswitch: $total_ovs_tests"
echo "Total tests (runtest.sh files) authored by Rick Alongi under kernel/networking/openvswitch: $total_rick_tests"
rick_pct=$(echo "scale=2 ; $total_rick_tests / $total_ovs_tests" | bc)
echo "Percentage of total OVS tests (runtest.sh files) that were created by Rick: $(echo "scale=2 ; $rick_pct * 100" | bc)%"
echo -e "\n"
echo "Details:"
echo "List of all runtest.sh files under kernel/networking/openvswitch ($total_ovs_tests):"
echo -e "\n"
cat /tmp/runtest_list.txt
echo -e "\n"
echo "List of all runtest.sh files created by Rick under kernel/networking/openvswitch ($total_rick_tests):"
echo -e "\n"
cat /tmp/rick_test_list

rm -f /tmp/runtest_list.txt
rm -f /tmp/rick_tests.txt
rm -f /tmp/rick_test_list

