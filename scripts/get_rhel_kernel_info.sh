#!/bin/bash

# Script to get RHEL and kernel version on target host

. /etc/os-release

rm -f /home/version_info.txt
echo "" >> /home/version_info.txt
echo "RHEL and Kernel version info for $(hostname):" >> /home/version_info.txt
echo "---------------------------------------------------------------------" >> /home/version_info.txt
echo "RHEL Version: $(echo $VERSION_ID)" >> /home/version_info.txt
echo "Kernel: $(uname -r)" >> //home/version_info.txt
echo "" >> /home/version_info.txt

cat /home/version_info.txt

