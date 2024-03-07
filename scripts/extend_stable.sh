#!/bin/bash

$dbg_flag

pushd ~

create_pssh_hosts_file()
{
	$dbg_flag
	if [[ $pssh_hosts_file == "pssh_stable_hosts_rhel8.txt" ]]; then
		for i in $stable_job_list_rhel8; do
			reservesys_status=$(bkr job-results --no-logs --prettyxml $i | grep /distribution/reservesys | grep 'status="Running"' | awk '{print $7}' | awk -F '"' '{print $2}')
			reservesys_result=$(bkr job-results --no-logs --prettyxml $i | grep '<result path="/distribution/reservesys"' | awk '{print $6}' | awk -F '"' '{print $2}')
			beaker_system=$(bkr job-results --no-logs --prettyxml $i | grep 'system value=' | awk -F'"' '{print $2}' | tail -n1)
			beaker_system_arch=$(bkr job-results --no-logs --prettyxml $i | grep distro_arch | awk -F '"' '{print $(NF-1)}')
			if [[ $reservesys_status == "Running" ]] && [[ $reservesys_result == "Pass" ]] ; then
				echo "$beaker_system $beaker_system_arch" >> $pssh_hosts_file
			fi
		done
		sleep 2
	elif [[ $pssh_hosts_file == "pssh_stable_hosts_rhel9.txt" ]]; then
		for i in $stable_job_list_rhel9; do
			reservesys_status=$(bkr job-results --no-logs --prettyxml $i | grep /distribution/reservesys | grep 'status="Running"' | awk '{print $7}' | awk -F '"' '{print $2}')
			reservesys_result=$(bkr job-results --no-logs --prettyxml $i | grep '<result path="/distribution/reservesys"' | awk '{print $6}' | awk -F '"' '{print $2}')
			beaker_system=$(bkr job-results --no-logs --prettyxml $i | grep 'system value=' | awk -F'"' '{print $2}' | tail -n1)
			beaker_system_arch=$(bkr job-results --no-logs --prettyxml $i | grep distro_arch | awk -F '"' '{print $(NF-1)}')
			if [[ $reservesys_status == "Running" ]] && [[ $reservesys_result == "Pass" ]] ; then
				echo "$beaker_system $beaker_system_arch" >> $pssh_hosts_file
			fi
		done
		sleep 2
	fi
}

check_pssh_hosts_file()
{
	$dbg_flag
	# check $pssh_hosts_file to confirm at least two of your systems are present
	if [[ $(bkr system-list --mine | grep $(head -n1 $pssh_hosts_file | awk '{print $1}')) ]] && [[ $(bkr system-list --mine | grep $(tail -n1 $pssh_hosts_file | awk '{print $1}')) ]]; then
		echo ""
		echo "Skipping creation of $pssh_hosts_file as it already exists and a beaker job list has been specified..."
		echo ""
	else
		echo ""
		echo "It looks like $pssh_hosts_file already exists but is incorrect.  Deleting and re-creating it now..."
		echo ""
		rm -f $pssh_hosts_file
		create_pssh_hosts_file
	fi
}

rm -f stable_jobs*
bkr job-list --mine --w "Stable system RHEL-8" >> stable_jobs_rhel8.txt
bkr job-list --mine --w "Stable system RHEL-9" >> stable_jobs_rhel9.txt
stable_job_list_rhel8=$(cat stable_jobs_rhel8.txt | tr -d '[",]]')
stable_job_list_rhel9=$(cat stable_jobs_rhel9.txt | tr -d '[",]]')

if [[ ! -s $pssh_hosts_file ]]; then
	create_pssh_hosts_file
fi

check_pssh_hosts_file

rm -f rhel8_pssh_hosts_file_full.tmp rhel9_pssh_hosts_file_full.tmp rhel_all_pssh_hosts_file_full.tmp
pssh_hosts_file="pssh_stable_hosts_rhel8.txt"
if [[ ! -s $pssh_hosts_file ]]; then
	create_pssh_hosts_file
fi

check_pssh_hosts_file
cat $pssh_hosts_file | awk '{print $1}' > rhel8_pssh_hosts_file_full.tmp
pssh_hosts_file="pssh_stable_hosts_rhel9.txt"
if [[ ! -s $pssh_hosts_file ]]; then
	create_pssh_hosts_file
fi

check_pssh_hosts_file
cat $pssh_hosts_file | awk '{print $1}' > rhel9_pssh_hosts_file_full.tmp

cat rhel8_pssh_hosts_file_full.tmp >> rhel_all_pssh_hosts_file_full.tmp
cat rhel9_pssh_hosts_file_full.tmp >> rhel_all_pssh_hosts_file_full.tmp

pssh -O StrictHostKeyChecking=no -p 8 -h rhel_all_pssh_hosts_file_full.tmp -t 0 -l root "extendtesttime.sh 99"

popd

