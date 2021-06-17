#!/bin/bash

echo "==================================================="

for i in {0..15}; do
        val1=$(grep -w 60 /tmp/log.$i | awk '{print $6}')
        val2=$(grep -w 60 /tmp/log_fix.$i | awk '{print $6}')
        echo "Tput for kernel without fix ($(cat /tmp/kver_pre_fix.txt)):   $val1 Mbps"
        echo "Tput for kernel with fix ($(cat /tmp/kver_fix.txt)):      $val2 Mbps"
        echo "===================================================="
done


