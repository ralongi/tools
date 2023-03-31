#!/bin/bash

$dbg_flag

pushd ~

rm -f rhel8_pssh_hosts_file_full.tmp rhel9_pssh_hosts_file_full.tmp rhel_all_pssh_hosts_file_full.tmp
pssh_hosts_file="pssh_stable_hosts_rhel8.txt"
cat $pssh_hosts_file | awk '{print $1}' > rhel8_pssh_hosts_file_full.tmp
pssh_hosts_file="pssh_stable_hosts_rhel9.txt"
cat $pssh_hosts_file | awk '{print $1}' > rhel9_pssh_hosts_file_full.tmp

cat rhel8_pssh_hosts_file_full.tmp >> rhel_all_pssh_hosts_file_full.tmp
cat rhel9_pssh_hosts_file_full.tmp >> rhel_all_pssh_hosts_file_full.tmp

pssh -O StrictHostKeyChecking=no -p 8 -h rhel_all_pssh_hosts_file_full.tmp -t 0 -l root "extendtesttime.sh 99"

popd

