#!/bin/sh

# script to create container image and upload it to fileserver
# on laptop

pushd ~
rhel_version=$1
arch=$2
if [[ -z $rhel_version ]] || [[ -z $arch ]]; then
	echo "Please provide a RHEL version and arch."
	echo "Example: $0 9.2 aarch64"
	exit 0
fi

skip_file_upload=${skip_file_upload:-"no"}
rhel_major_version=$(echo $rhel_version  | awk -F '.' '{print $1}')

tmp0=$(mktemp)
. /home/ralongi/github/tools/scripts/get_dpdk_packages.sh
get_dpdk_packages $rhel_version $arch
RPM_DPDK=$(echo $RPM_DPDK | sed s/https/http/g)
RPM_DPDK_TOOLS=$(echo $RPM_DPDK_TOOLS | sed s/https/http/g)

get_latest_driverctl()
{
	$dbg_flag
	latest_build_id=$(curl -sL http://download.devel.redhat.com/brewroot/packages/driverctl | grep -B1 '<hr></pre>' | grep DIR | awk -F '"' '{print $6}' | tr -d '/')

	latest_el8_package_id=$(curl -sL http://download.devel.redhat.com/brewroot/packages/driverctl/$latest_build_id/ | grep el8 | head -n1 |  awk -F '"' '{print $6}' | tr -d '/')

	latest_el9_package_id=$(curl -sL http://download.devel.redhat.com/brewroot/packages/driverctl/$latest_build_id/ | grep el9 | tail -n1 |  awk -F '"' '{print $6}' | tr -d '/')

	el8_rpm=$(curl -sL http://download.devel.redhat.com/brewroot/packages/driverctl/$latest_build_id/$latest_el8_package_id/noarch/ | grep rpm | awk -F '"' '{print $6}')

	el9_rpm=$(curl -sL http://download.devel.redhat.com/brewroot/packages/driverctl/$latest_build_id/$latest_el9_package_id/noarch/ | grep rpm | awk -F '"' '{print $6}')

	export DRIVERCTL_RHEL8="http://download.devel.redhat.com/brewroot/packages/driverctl/$latest_build_id/$latest_el8_package_id/noarch/$el8_rpm"
	export DRIVERCTL_RHEL9="http://download.devel.redhat.com/brewroot/packages/driverctl/$latest_build_id/$latest_el9_package_id/noarch/$el9_rpm"
}

get_latest_driverctl

if [[ $rhel_major_version -eq 8 ]]; then
	driverctl=$DRIVERCTL_RHEL8
elif [[ $rhel_major_version -eq 9 ]]; then
	driverctl=$DRIVERCTL_RHEL9
fi

if [[ -n $target_system ]]; then
	echo "Logging into $target_system to create container image..."
	cat /home/ralongi/github/tools/scripts/create_remote_container.sh | ssh -q -o "StrictHostKeyChecking= no" root@$target_system 'bash -'
else
	# launch beaker job to reserve and provision target system

	~/github/tools/scripts/get_beaker_compose_id.sh $rhel_version | tee $tmp0
	distro=$(grep latest $tmp0 | awk '{print $NF}')
	## add options below to reserve system after install (maybe use runtest instead of bkr workflow-simple)
	bkr workflow-tomorrow --distro=$distro --arch=$arch --id | tee $tmp0
	job_id=$(cat $tmp0)
	job_id="J:"$job_id
	echo "Sleeping 5 minutes for system to be selected by beaker job $job_id..."
	sleep 5m
	target_system=$(bkr job-results $job_id --prettyxml | grep 'system value' | tail -n1 | awk -F '"' '{print $2}')
	if [[ -z $target_system ]]; then
		sleep 5m
		target_system=$(bkr job-results $job_id --prettyxml | grep 'system value' | tail -n1 | awk -F '"' '{print $2}')
	fi

	if [[ -z $target_system ]]; then
		short_job_id=$(echo $job_id | awk -F ':' '{print $NF}')
		echo "https://beaker.engineering.redhat.com/jobs/$short_job_id hasn't grabbed a system after 10 minutes.  Exiting this script..."
		exit 1
	fi

	echo "Target system is: $target_system"

	rm -f $tmp0
	popd
	
	if [[ $arch == "ppc64le" ]]; then
		sleep 30m
	else
		sleep 15m
	fi

	ssh -q -o "StrictHostKeyChecking no" root@$target_system exit
	if [[ $? -ne 0 ]]; then sleep 10m; fi

	ssh -q -o "StrictHostKeyChecking no" root@$target_system exit
	if [[ $? -ne 0 ]]; then echo "Can't ssh to $target_system.  Exiting..."; exit 1; fi

	echo "Logging into $target_system to create container image..."
	cat /home/ralongi/github/tools/scripts/create_remote_container.sh | ssh -q -o "StrictHostKeyChecking= no" root@$target_system 'bash -'
fi
bkr job-cancel $job_id
