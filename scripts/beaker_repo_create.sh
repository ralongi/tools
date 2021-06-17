#!/bin/bash

set -x

# This script can be used to create beaker repo files on lab machines to point to the latest stable compose

target=$1
password=$2
rhel_version=$(cut -f1 -d. /etc/redhat-release | sed 's/[^0-9]//g')

#create the display usage to be presented to the user
display_usage(){
	echo -e "\n"$0" [target hostname or IP address] [root password]"
	echo -e "Example: "$0" qe-dell-ovs2.knqe.lab.eng.bos.redhat.com  redhat (assumes username of \"root\")\n"
}

#if less than 2 argument2 supplied by the user, display usage
if [ $# -lt 2 ]
then
display_usage
exit 1
fi

#check whether user has supplied -h or --help or help or -?.  if yes, display usage
if [[ $# == "--help" || $# == "help" || $# == "-h" || $# == "-?" ]]
then
display_usage
exit 1
fi

epe_install()
{
	ls /etc/yum.repos.d/*epel*; if [[ $? == 0 ]]; then return 0; fi
	timeout 60s bash -c "until ping -c3 download.bos.redhat.com; do sleep 10; done"
	
	if (($rhel_version == 6)); then
		rpm -ivh http://download.bos.redhat.com/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm
	elif (($rhel_version == 7)); then
		rpm -ivh http://download.bos.redhat.com/pub/epel/7/x86_64/e/epel-release-7-5.noarch.rpm
	fi
}

sshpass_install()
{
	yum -y install sshpass || true
}

epe_install

sshpass_install

sshpass -p $password ssh root@$target << "EOF"

	rhel_version=$(cut -f1 -d. /etc/redhat-release | sed 's/[^0-9]//g')

	# back up original repo files
	if [ -e /etc/yum.repos.d/orig ]; then
		echo "Original repo files already backed up."
	else
		mkdir /etc/yum.repos.d/orig && mv /etc/yum.repos.d/*.repo /etc/yum.repos.d/orig/
	fi

	if (($rhel_version == 6)); then

		# create beaker-Server.repo file
		(
			echo [beaker-Server]
			echo name=beaker-Server
			echo baseurl=http://download.eng.bos.redhat.com/rel-eng/latest-RHEL-6/compose/Server/x86_64/os/
			echo enabled=1
			echo gpgcheck=0
			echo skip_if_unavailable=1
		) > /etc/yum.repos.d/beaker-Server.repo

		# create beaker-Server-optional.repo file
		(
			echo [beaker-Server-optional]
			echo name=beaker-Server-optional
			echo baseurl=http://download.eng.bos.redhat.com/rel-eng/latest-RHEL-6/compose/Server/optional/x86_64/os/
			echo enabled=1
			echo gpgcheck=0
			echo skip_if_unavailable=1
		) > /etc/yum.repos.d/beaker-Server-optional.repo

		# create beaker-HighAvailability.repo file
		(
			echo [beaker-HighAvailability]
			echo name=beaker-HighAvailability
			echo baseurl=http://download.devel.redhat.com/rel-eng/latest-RHEL-6/compose/Server/x86_64/os/HighAvailability
			echo enabled=1
			echo gpgcheck=0
			echo skip_if_unavailable=1
		) > /etc/yum.repos.d/beaker-HighAvailability.repo

		# create beaker-LoadBalancer.repo file
		(
			echo [beaker-LoadBalancer]
			echo name=beaker-LoadBalancer
			echo baseurl=http://download.devel.redhat.com/rel-eng/latest-RHEL-6/compose/Server/x86_64/os/LoadBalancer
			echo enabled=1
			echo gpgcheck=0
			echo skip_if_unavailable=1
		) > /etc/yum.repos.d/beaker-LoadBalancer.repo

		# create beaker-ResilientStorage.repo file
		(
			echo [beaker-ResilientStorage]
			echo name=beaker-ResilientStorage
			echo baseurl=http://download.devel.redhat.com/rel-eng/latest-RHEL-6/compose/Server/x86_64/os/ResilientStorage
			echo enabled=1
			echo gpgcheck=0
			echo skip_if_unavailable=1
		) > /etc/yum.repos.d/beaker-ResilientStorage.repo

		# create beaker-ScalableFileSystem.repo file
		(
			echo [beaker-ScalableFileSystem]
			echo name=beaker-ScalableFileSystem
			echo baseurl=http://download.devel.redhat.com/rel-eng/latest-RHEL-6/compose/Server/x86_64/os/ScalableFileSystem
			echo enabled=1
			echo gpgcheck=0
			echo skip_if_unavailable=1
		) > /etc/yum.repos.d/beaker-ScalableFileSystem.repo

		# create beaker-Server-debuginfo.repo file
		(
			echo [beaker-Server-debuginfo]
			echo name=beaker-Server-debuginfo
			echo baseurl=http://download.devel.redhat.com/rel-eng/latest-RHEL-6/compose/Server/x86_64/debug
			echo enabled=1
			echo gpgcheck=0
			echo skip_if_unavailable=1
		) > /etc/yum.repos.d/beaker-Server-debuginfo.repo

		# create beaker-Server-optional-debuginfo.repo file
		(
			echo [beaker-Server-optional-debuginfo]
			echo name=beaker-Server-optional-debuginfo
			echo baseurl=http://download.devel.redhat.com/rel-eng/latest-RHEL-6/compose/Server/optional/x86_64/debug
			echo enabled=1
			echo gpgcheck=0
		echo skip_if_unavailable=1
		) > /etc/yum.repos.d/beaker-Server-optional-debuginfo.repo

		# create beaker-Server-SAP-debuginfo.repo file
		(
			echo [beaker-Server-SAP-debuginfo]
			echo name=beaker-Server-SAP-debuginfo
			echo baseurl=http://download.devel.redhat.com/rel-eng/latest-RHEL-6/compose/Server-SAP/x86_64/debug
			echo enabled=1
			echo gpgcheck=0
			echo skip_if_unavailable=1
		) > /etc/yum.repos.d/beaker-Server-SAP-debuginfo.repo

		# create beaker-Server-SAPHANA-debuginfo.repo file
		(
			echo [beaker-Server-SAPHANA-debuginfo]
			echo name=beaker-Server-SAPHANA-debuginfo
			echo baseurl=http://download.devel.redhat.com/rel-eng/latest-RHEL-6/compose/Server-SAPHANA/x86_64/debug
			echo enabled=1
			echo gpgcheck=0
			echo skip_if_unavailable=1
		) > /etc/yum.repos.d/beaker-Server-SAPHANA-debuginfo.repo

		# create beaker-Server-SAPHANA.repo file
		(
			echo [beaker-Server-SAPHANA]
			echo name=beaker-Server-SAPHANA
			echo baseurl=http://download.devel.redhat.com/rel-eng/latest-RHEL-6/compose/Server-SAPHANA/x86_64/os
			echo enabled=1
			echo gpgcheck=0
			echo skip_if_unavailable=1
		) > /etc/yum.repos.d/beaker-Server-SAPHANA.repo

		# create beaker-Server-SAP.repo file
		(
			echo [beaker-Server-SAP]
			echo name=beaker-Server-SAP
			echo baseurl=http://download.devel.redhat.com/rel-eng/latest-RHEL-6/compose/Server-SAP/x86_64/os
			echo enabled=1
			echo gpgcheck=0
			echo skip_if_unavailable=1
		) > /etc/yum.repos.d/beaker-Server-SAP.repo

	elif (($rhel_version == 7)); then

			# create beaker-Server.repo file
		(
			echo [beaker-Server]
			echo name=beaker-Server
			echo baseurl=http://download.eng.bos.redhat.com/rel-eng/latest-RHEL-7/compose/Server/x86_64/os/
			echo enabled=1
			echo gpgcheck=0
			echo skip_if_unavailable=1
		) > /etc/yum.repos.d/beaker-Server.repo

		# create beaker-Server-optional.repo file
		(
			echo [beaker-Server-optional]
			echo name=beaker-Server-optional
			echo baseurl=http://download.eng.bos.redhat.com/rel-eng/latest-RHEL-7/compose/Server/optional/x86_64/os/
			echo enabled=1
			echo gpgcheck=0
			echo skip_if_unavailable=1
		) > /etc/yum.repos.d/beaker-Server-optional.repo

		# create beaker-HighAvailability.repo file
		(
			echo [beaker-HighAvailability]
			echo name=beaker-HighAvailability
			echo baseurl=http://download.devel.redhat.com/rel-eng/latest-RHEL-7/compose/Server/x86_64/os/HighAvailability
			echo enabled=1
			echo gpgcheck=0
			echo skip_if_unavailable=1
		) > /etc/yum.repos.d/beaker-HighAvailability.repo

		# create beaker-LoadBalancer.repo file
		(
			echo [beaker-LoadBalancer]
			echo name=beaker-LoadBalancer
			echo baseurl=http://download.devel.redhat.com/rel-eng/latest-RHEL-7/compose/Server/x86_64/os/LoadBalancer
			echo enabled=1
			echo gpgcheck=0
			echo skip_if_unavailable=1
		) > /etc/yum.repos.d/beaker-LoadBalancer.repo

		# create beaker-ResilientStorage.repo file
		(
			echo [beaker-ResilientStorage]
			echo name=beaker-ResilientStorage
			echo baseurl=http://download.devel.redhat.com/rel-eng/latest-RHEL-7/compose/Server/x86_64/os/ResilientStorage
			echo enabled=1
			echo gpgcheck=0
			echo skip_if_unavailable=1
		) > /etc/yum.repos.d/beaker-ResilientStorage.repo

		# create beaker-ScalableFileSystem.repo file
		(
			echo [beaker-ScalableFileSystem]
			echo name=beaker-ScalableFileSystem
			echo baseurl=http://download.devel.redhat.com/rel-eng/latest-RHEL-7/compose/Server/x86_64/os/ScalableFileSystem
			echo enabled=1
			echo gpgcheck=0
			echo skip_if_unavailable=1
		) > /etc/yum.repos.d/beaker-ScalableFileSystem.repo

		# create beaker-Server-debuginfo.repo file
		(
			echo [beaker-Server-debuginfo]
			echo name=beaker-Server-debuginfo
			echo baseurl=http://download.devel.redhat.com/rel-eng/latest-RHEL-7/compose/Server/x86_64/debug
			echo enabled=1
			echo gpgcheck=0
			echo skip_if_unavailable=1
		) > /etc/yum.repos.d/beaker-Server-debuginfo.repo

		# create beaker-Server-optional-debuginfo.repo file
		(
			echo [beaker-Server-optional-debuginfo]
			echo name=beaker-Server-optional-debuginfo
			echo baseurl=http://download.devel.redhat.com/rel-eng/latest-RHEL-7/compose/Server/optional/x86_64/debug
			echo enabled=1
			echo gpgcheck=0
			echo skip_if_unavailable=1
		) > /etc/yum.repos.d/beaker-Server-optional-debuginfo.repo

		# create beaker-Server-SAP-debuginfo.repo file
		(
			echo [beaker-Server-SAP-debuginfo]
			echo name=beaker-Server-SAP-debuginfo
			echo baseurl=http://download.devel.redhat.com/rel-eng/latest-RHEL-7/compose/Server-SAP/x86_64/debug
			echo enabled=1
			echo gpgcheck=0
			echo skip_if_unavailable=1
		) > /etc/yum.repos.d/beaker-Server-SAP-debuginfo.repo

		# create beaker-Server-SAPHANA-debuginfo.repo file
		(
			echo [beaker-Server-SAPHANA-debuginfo]
			echo name=beaker-Server-SAPHANA-debuginfo
			echo baseurl=http://download.devel.redhat.com/rel-eng/latest-RHEL-7/compose/Server-SAPHANA/x86_64/debug
			echo enabled=1
			echo gpgcheck=0
			echo skip_if_unavailable=1
		) > /etc/yum.repos.d/beaker-Server-SAPHANA-debuginfo.repo

		# create beaker-Server-SAPHANA.repo file
		(
			echo [beaker-Server-SAPHANA]
			echo name=beaker-Server-SAPHANA
			echo baseurl=http://download.devel.redhat.com/rel-eng/latest-RHEL-7/compose/Server-SAPHANA/x86_64/os
			echo enabled=1
			echo gpgcheck=0
			echo skip_if_unavailable=1
		) > /etc/yum.repos.d/beaker-Server-SAPHANA.repo

		# create beaker-Server-SAP.repo file
		(
			echo [beaker-Server-SAP]
			echo name=beaker-Server-SAP
			echo baseurl=http://download.devel.redhat.com/rel-eng/latest-RHEL-7/compose/Server-SAP/x86_64/os
			echo enabled=1
			echo gpgcheck=0
			echo skip_if_unavailable=1
		) > /etc/yum.repos.d/beaker-Server-SAP.repo
	else
		echo "The system is not running RHEL 6 or RHEL 7."
		exit 1
	fi
EOF


