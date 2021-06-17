#!/bin/bash

# config_host.sh script to run after provisioning system

# usage: ssh root@host.domain < config_host.sh

# rhel version
rhel_version=$(cut -f1 -d. /etc/redhat-release | sed 's/[^0-9]//g')

# install beaker-client.repo
wget -O /etc/yum.repos.d/beaker-client.repo http://download.lab.bos.redhat.com/beakerrepos/beaker-client-RedHatEnterpriseLinux.repo

# install beaker related packages
yum -y install rhts-test-env beakerlib rhts-devel rhts-python beakerlib-redhat beaker-client beaker-redhat

# create beaker-tasks.repo file
(
	echo [beaker-tasks]
	echo name=beaker-tasks
	echo baseurl=http://beaker.engineering.redhat.com/rpms
	echo enabled=1
	echo gpgcheck=0
	echo skip_if_unavailable=1
) > /etc/yum.repos.d/beaker-tasks.repo

git_install()
{
	if [ $# -gt 0 ]; then 
		git_dir=$1
	else
		git_dir="/mnt/git_repo"
	fi

	if rpm -q git 2>/dev/null; then
		echo "Git is already installed; doing a git pull"; cd "$git_dir"/kernel; git pull
		return 0
	else
	    yum -y install git
        mkdir "$git_dir"
		cd "$git_dir" && git clone git://pkgs.devel.redhat.com/tests/kernel
	fi
}

# install git
git_install /mnt/tests

# source necessary files
# include Beaker environment
. /mnt/tests/kernel/networking/common/include.sh || exit 1
 
# include common install functions
. /mnt/tests/kernel/networking/common/install.sh || exit 1

# include common networking functions
. /mnt/tests/kernel/networking/common/network.sh || exit 1
. /mnt/tests/kernel/networking/common/lib/lib_nc_sync.sh || exit 1
#. /mnt/tests/kernel/networking/common/lib/lib_netperf_all.sh || exit 1

# include private common functions
. /mnt/tests/kernel/networking/impairment/networking_common.sh || exit 1
. /mnt/tests/kernel/networking/impairment/install.sh || exit 1
. /mnt/tests/kernel/networking/openvswitch/tests/perf_check/lib_netperf_all.sh || exit 1

# stop security features
iptables_stop_flush && setenforce 0

# update beaker repo files
do_beaker_repo_create

# install miscellaneous packages
# epel repo
epe_install

# netperf
netperf_install
pkill netserver; sleep 2; netserver

# sshpass
sshpass_install

# httpd
httpd_install

# ovs
ovs_install

#virtualization
virt_install

# install ip netns
iproute2_install

# brctl
brctl_install

# NetworkManager
networkmanager_install

