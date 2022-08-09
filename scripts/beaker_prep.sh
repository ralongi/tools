#!/bin/bash

echo "sslverify=false" >> /etc/yum.conf

# install wget in case it's missing
yum -y install wget

# install beaker-client.repo
wget -O /etc/yum.repos.d/beaker-client.repo http://download.lab.bos.redhat.com/beakerrepos/beaker-client-RedHatEnterpriseLinux.repo

# create beaker-tasks.repo file
(
	echo [beaker-tasks]
	echo name=beaker-tasks
	echo baseurl=http://beaker.engineering.redhat.com/rpms
	echo enabled=1
	echo gpgcheck=0
	echo skip_if_unavailable=1
) > /etc/yum.repos.d/beaker-tasks.repo

# create beaker-harness.repo file
(
	echo [beaker-harness]
	echo name=beaker-harness
	echo baseurl=http://download.eng.bos.redhat.com/beakerrepos/harness-testing/RedHatEnterpriseLinux8/
	echo enabled=1
	echo gpgcheck=0
	echo skip_if_unavailable=1
) > /etc/yum.repos.d/beaker-harness.repo

# install beaker related packages
yum -y install rhts-test-env beakerlib rhts-devel rhts-python beakerlib-redhat.noarch beaker-client beaker-redhat

yum -y install kernel-networking-common
source /mnt/tests/kernel/networking/common/include.sh

# install target packages (example below)
yum -y install kernel-networking-openvswitch-common kernel-networking-openvswitch-memory_leak_soak kernel-networking-openvswitch-topo

# install git
git_install()
{
	if [ $# -gt 0 ]; then 
		git_dir=$1
	else
		git_dir="/mnt/git_repo"
	fi
	
	echo "Installing Git if not already installed and cloning repo..."
    yum -y install git || true
    mkdir "$git_dir"
	pushd "$git_dir" && git clone http://git.app.eng.bos.redhat.com/git/kernel-tests.git && popd
}

git_install /mnt/tests

. /mnt/tests/kernel/networking/impairment/install.sh
. /mnt/tests/kernel/networking/impairment/networking_common.sh
. /mnt/tests/kernel/networking/openvswitch/lib_config.sh
. /mnt/tests/kernel/networking/openvswitch/perf_check/lib_perf_check.sh

#openvswitch_rpm="http://download.eng.bos.redhat.com/brewroot/packages/openvswitch/2.5.0/3.el7/x86_64/openvswitch-2.5.0-3.el7.x86_64.rpm"
pvt_ovs_install

pvt_virt_install

pvt_iproute2_install

