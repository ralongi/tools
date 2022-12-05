#!/bin/bash

# script to run tps jobs remotely from laptop after all stable systems have been built and are running
# You MUST export $errata in terminal window before running this script
# Example: export errata=2022:123456

$dbg_flag
errata=${errata:-""}

display_usage()
{
	echo "Usage: run_tps [rhn]"
	echo "The 'rhn' switch is optional.  If specified, the tps-rhnqa tests will be run on the stable systems."
	echo "Be sure to execute: export errata=<errata ID> in terminal window before running this"
}

if [[ $1 = "-h" ]] || [[ $1 = "--help" ]]	|| [[ $1 = "-?" ]]; then
	display_usage
fi

if [[ -z $errata ]]; then
	echo "You must export the errata ID in the terminal window before running this script"
	echo "Example: export errata=2022:123456"
	exit 1
fi

if [[ $(curl -su : --negotiate https://errata.devel.redhat.com/api/v1/erratum/$errata/builds | jq | grep RHEL-8) ]]; then
	pssh_hosts_file="/home/ralongi/temp/pssh_stable_hosts_rhel8"
elif [[ $(curl -su : --negotiate https://errata.devel.redhat.com/api/v1/erratum/$errata/builds | jq | grep RHEL-9) ]]; then
	pssh_hosts_file="/home/ralongi/temp/pssh_stable_hosts_rhel9"
fi

while true; do
    read -p "Have you confirmed that you have exported the correct errata ID in this window?" yn
    case $yn in
        [Yy]* ) break;;
        [Nn]* ) exit;;
        * ) echo "Please answer yes or no.";;
        esac
done

rm -f ~/temp/stable_jobs*
bkr job-list --mine --w "Stable system RHEL-8" | tee -a ~/temp/stable_jobs_rhel8.txt
bkr job-list --mine --w "Stable system RHEL-9" | tee -a ~/temp/stable_jobs_rhel9.txt
stable_job_list_rhel8=$(cat /home/ralongi/temp/stable_jobs_rhel8.txt | tr -d '[",]]')
stable_job_list_rhel9=$(cat /home/ralongi/temp/stable_jobs_rhel9.txt | tr -d '[",]]') 

# RHEL-8
if [[ $pssh_hosts_file == "/home/ralongi/temp/pssh_stable_hosts_rhel8" ]]; then
	if [[ $stable_job_list_rhel8 ]] && [[ ! -s $pssh_hosts_file ]]; then
		for i in $stable_job_list_rhel8; do
			reservesys_status=$(bkr job-results --no-logs --prettyxml $i | grep /distribution/reservesys | grep 'status="Running"' | awk '{print $7}' | awk -F '"' '{print $2}')
			reservesys_result=$(bkr job-results --no-logs --prettyxml $i | grep '<result path="/distribution/reservesys"' | awk '{print $6}' | awk -F '"' '{print $2}')
			beaker_system=$(bkr job-results --no-logs --prettyxml $i | grep 'system value=' | awk -F'"' '{print $2}' | tail -n1)
			if [[ $reservesys_status == "Running" ]] && [[ $reservesys_result == "Pass" ]] ; then
				echo $beaker_system >> $pssh_hosts_file
			fi
		done
		sleep 2
	else
		# check $pssh_hosts_file to confirm at least two of your systems are present
		if [[ $(bkr system-list --mine | grep $(head -n1 $pssh_hosts_file)) ]] && [[ $(bkr system-list --mine | grep $(tail -n1 $pssh_hosts_file)) ]]; then
			echo "Skipping creation of $pssh_hosts_file as it already exists and a beaker job list has been specified..."
		else
			echo "You better check $pssh_hosts_file to make sure it's correct"
			echo "There may be an old file laying around that needs to be deleted"
			exit 1
		fi
	fi
fi

# RHEL-9
if [[ $pssh_hosts_file == "/home/ralongi/temp/pssh_stable_hosts_rhel9" ]]; then
	if [[ $stable_job_list_rhel9 ]] && [[ ! -s $pssh_hosts_file ]]; then
		for i in $stable_job_list_rhel9; do
			reservesys_status=$(bkr job-results --no-logs --prettyxml $i | grep /distribution/reservesys | grep 'status="Running"' | awk '{print $7}' | awk -F '"' '{print $2}')
			reservesys_result=$(bkr job-results --no-logs --prettyxml $i | grep '<result path="/distribution/reservesys"' | awk '{print $6}' | awk -F '"' '{print $2}')
			beaker_system=$(bkr job-results --no-logs --prettyxml $i | grep 'system value=' | awk -F'"' '{print $2}' | tail -n1)
			if [[ $reservesys_status == "Running" ]] && [[ $reservesys_result == "Pass" ]] ; then
				echo $beaker_system >> $pssh_hosts_file
			fi
		done
		sleep 2
	else
		# check $pssh_hosts_file to confirm at least two of your systems are present
		if [[ $(bkr system-list --mine | grep $(head -n1 $pssh_hosts_file)) ]] && [[ $(bkr system-list --mine | grep $(tail -n1 $pssh_hosts_file)) ]]; then
			echo "Skipping creation of $pssh_hosts_file as it already exists and a beaker job list has been specified..."
		else
			echo "You better check $pssh_hosts_file to make sure it's correct"
			echo "There may be an old file laying around that needs to be deleted"
			exit 1
		fi
	fi
fi

if [[ $(cat $pssh_hosts_file | wc -l) -ne 4 ]]; then
	echo "Looks like not all of the stable systems have been built yet.  Exiting..."
	exit 0
fi

echo "pssh hosts file to be used: $pssh_hosts_file"
echo "Contents of $pssh_hosts_file:"
cat $pssh_hosts_file

pssh -h $pssh_hosts_file -t 0 -l root sed -i \"/^export errata=/c export errata=$errata\" /root/tps_run_tests.sh > /dev/null
pssh -h $pssh_hosts_file -t 0 -l root sed -i \"/^export errata=/c export errata=$errata\" /root/tps_run_rhnqa_tests.sh > /dev/null

if [[ "$*" == *"rhn"* ]]; then
	pssh -h $pssh_hosts_file -t 0 -l root /root/tps_run_rhnqa_tests.sh
else
	pssh -h $pssh_hosts_file -t 0 -l root /root/tps_run_tests.sh
fi
