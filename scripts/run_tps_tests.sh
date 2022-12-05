#!/bin/bash

$dbg_flag
errata_dir=/mnt/qa/scratch/$(hostname -s)/$errata/tps

if [[ "$*" == *"rhn"* ]]; then
	tps_cmd="tps-rhnqa"
	skip_stable_setup="yes"
else
	if [[ $(grep 'OVERALL TEST RESULT' $errata_dir/tps-make-lists.report | awk '{print $NF}') == "PASS" ]]; then
		tps_cmd="tps -m"
	else
		tps_cmd="tps"
	fi
fi

# Before executing this script in the terminal window, first type: export errata=<errata> (i.e. export errata=2022:104365)

extendtesttime.sh 99
if [[ $skip_stable_setup != "yes" ]]; then ~/stable_cleanup.sh; fi
export TPSQ_RHNDEST="fast-datapath-for-rhel-8-$(uname -m)-rpms"
. /etc/profile.d/tps-cd.sh
tps-cd $errata && $tps_cmd | tee ~/"$tps_cmd"_"$errata"_$(uname -m).txt

if [[ $(/mnt/qa/scratch/rbiba/tps-utils/tps-get-jobs $errata | egrep "$(uname -m)" | wc -l) -eq 2 ]] && [[ $tps_cmd == "tps-rhnqa" ]]; then
	export jobid=$(/mnt/qa/scratch/rbiba/tps-utils/tps-get-jobs $errata | grep -E "$(uname -m)" | awk -F ',' '{print $1}' | tail -n1)
else
	export jobid=$(/mnt/qa/scratch/rbiba/tps-utils/tps-get-jobs $errata | grep -E "$(uname -m)" | awk -F ',' '{print $1}' | head -n1)
fi

if [[ $tps_cmd == "tps-rhnqa" ]]; then
	tps_result=$(grep 'OVERALL' ~/"$tps_cmd"_"$errata"_$(uname -m).txt | awk '{print $NF}')
else
	tps_result=$(grep 'OVERALL' ~/"$tps_cmd"_"$errata"_$(uname -m).txt | grep $errata| awk '{print $NF}')
fi	

if [[ $tps_result == "PASS" ]]; then
	~/upload_tps.sh
else
	echo "OVERALL TPS/TPS_RHNQA RESULT: $tps_result"
	echo "Exiting..."
	exit 1
fi

cd ~
