#!/bin/bash

# This script can be used to create beaker repo files on lab machines to point to the latest stable compose

target=$1

#create the display usage to be presented to the user
display_usage(){
	echo -e "\n"$0" [target hostname or IP address]"
	echo -e "Example: "$0" qe-dell-ovs2.knqe.lab.eng.bos.redhat.com (assumes username of \"root\" with password \"redhat\")\n"
}

#if less than 1 argument is supplied by the user, display usage
if [ $# -lt 1 ]
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

sshpass -p redhat ssh root@$target << "EOF"

	# back up original repo files
	cd /etc/yum.repos.d && mkdir orig
	mv beaker*.repo ./orig

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

	# install epel repo for RHEL 6
	wget http://download.bos.redhat.com/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm
	rpm -ivh epel-release-6-8.noarch.rpm
	rm -f epel-release-6-8.noarch.rpm
EOF


