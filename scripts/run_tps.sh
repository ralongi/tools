#!/bin/bash

# script to run tps jobs remotely from laptop after all stable systems have been built and are running
# You MUST export $errata in terminal window before running this script
# Example: export errata=2022:123456

$dbg_flag
errata=${errata:-""}

display_usage()
{
	echo ""
	echo "Usage: run_tps [rhn] [arch=<arch>]"
	echo "The 'rhn' and 'arch=' switches are optional."
	echo "If 'rhn' is specified, the tps-rhnqa tests will be run on all of the stable systems."
	echo "If 'arch=<arch>' is specified, the tps or tps-rhnqa tests will be run on all of the specific stable systems running that arch(s)."
	echo '"Examples: run_tps, run_tps rhn, run_tps arch=ppc64le, run_tps rhn arch="x86_64 aarch64"'
	echo "Be sure to execute: export errata=<errata ID> in terminal window before running this."
	echo ""
	exit 0
}

if [[ $1 = "-h" ]] || [[ $1 = "--h" ]] || [[ $1 = "--help" ]] || [[ $1 = "-help" ]] || [[ $1 = "-?" ]] || [[ $1 = "--?" ]]; then
	display_usage
fi

if [[ -z $errata ]]; then
	echo "You must export the errata ID in the terminal window before running this script"
	echo "Example: export errata=2022:123456"
	exit 1
fi

pushd ~

if [[ $(curl -su : --negotiate https://errata.devel.redhat.com/api/v1/erratum/$errata/builds | jq | grep RHEL-8) ]]; then
	pssh_hosts_file="pssh_stable_hosts_rhel8.txt"
elif [[ $(curl -su : --negotiate https://errata.devel.redhat.com/api/v1/erratum/$errata/builds | jq | grep RHEL-9) ]]; then
	pssh_hosts_file="pssh_stable_hosts_rhel9.txt"
fi

while true; do
    read -p "Is errata $errata correct? " yn
    case $yn in
        [Yy]* ) break;;
        [Nn]* ) exit;;
        * ) echo "Please answer yes or no.";;
        esac
done

rm -f stable_jobs*
bkr job-list --mine --w "Stable system RHEL-8" >> stable_jobs_rhel8.txt
bkr job-list --mine --w "Stable system RHEL-9" >> stable_jobs_rhel9.txt
stable_job_list_rhel8=$(cat stable_jobs_rhel8.txt | tr -d '[",]]')
stable_job_list_rhel9=$(cat stable_jobs_rhel9.txt | tr -d '[",]]')

create_pssh_hosts_file()
{
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

if [[ ! -s $pssh_hosts_file ]]; then
	create_pssh_hosts_file
fi

check_pssh_hosts_file

if [[ ! "$*" == *"arch="* ]] && [[ $(cat $pssh_hosts_file | wc -l) -ne 4 ]]; then
	echo "Looks like not all of the stable systems have been built yet.  Exiting..."
	exit 0
fi

echo "pssh hosts file to be used: $pssh_hosts_file"
echo ""
echo "Contents of $pssh_hosts_file:"
echo ""
cat $pssh_hosts_file
echo ""

cat $pssh_hosts_file | awk '{print $1}' > pssh_hosts_file_full.tmp

pssh -O StrictHostKeyChecking=no -p 4 -h pssh_hosts_file_full.tmp -t 0 -l root sed -i \"/^export errata=/c export errata=$errata\" /root/tps_run_tests.sh > /dev/null
pssh -O StrictHostKeyChecking=no -p 4 -h pssh_hosts_file_full.tmp -t 0 -l root sed -i \"/^export errata=/c export errata=$errata\" /root/tps_run_rhnqa_tests.sh > /dev/null

if [[ "$*" == *"rhn"* ]] && [[ "$*" == *"arch="* ]]; then
	arch=$(echo "$*" | awk -F 'arch=' '{print $NF}')
	rm -f pssh_hosts_file.tmp
	for i in $arch; do
		grep "$i" $pssh_hosts_file | awk '{print $1}' >> pssh_hosts_file.tmp
	done
	echo ""
	echo ""
	echo "Running rhnqa-tps on:"
	cat pssh_hosts_file.tmp
	echo ""
	pssh -O StrictHostKeyChecking=no -h pssh_hosts_file.tmp -t 0 -l root /root/tps_run_rhnqa_tests.sh
elif [[ "$*" == *"arch="* ]]; then
	arch=$(echo "$*" | awk -F 'arch=' '{print $NF}')
	rm -f pssh_hosts_file.tmp
	for i in $arch; do
		grep "$i" $pssh_hosts_file | awk '{print $1}' >> pssh_hosts_file.tmp
	done
	echo ""
	echo ""
	echo "Running tps on:"
	cat pssh_hosts_file.tmp
	echo ""
	pssh -O StrictHostKeyChecking=no -h pssh_hosts_file.tmp -t 0 -l root /root/tps_run_tests.sh
elif [[ "$*" == *"rhn"* ]]; then
	echo ""
	echo "Systems to be used:"
	echo ""
	cat pssh_hosts_file_full.tmp
	echo ""
	echo "Running rhnqa-tps on systems listed above..."
	echo ""
	pssh -O StrictHostKeyChecking=no -p 4 -h pssh_hosts_file_full.tmp -t 0 -l root /root/tps_run_rhnqa_tests.sh
else
	echo ""
	echo "Systems to be used:"
	echo ""
	cat pssh_hosts_file_full.tmp
	echo ""
	echo "Running tps on systems listed above..."
	echo ""
	pssh -O StrictHostKeyChecking=no -p 4 -h pssh_hosts_file_full.tmp -t 0 -l root /root/tps_run_tests.sh
fi

popd
