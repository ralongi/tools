#!/bin/bash

# install wget in case it's missing
yum -y install wget

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

# install git
git_install()
{
	if rpm -q git 2>/dev/null; then
		echo "Git is already installed; doing a git pull"; cd /mnt/tests/kernel; git pull
		return 0
	else
	        yum -y install git
        	mkdir /mnt/tests
		cd /mnt/tests && git clone git://pkgs.devel.redhat.com/tests/kernel
	fi
}

git_install

# download test files from repo
rm -f /home/runtest.sh /home/Makefile /home/PURPOSE
wget -nv -O /home/runtest.sh http://netqe-infra01.knqe.eng.rdu2.dc.redhat.com/temp/runtest.sh
wget -nv -O /home/Makefile http://netqe-infra01.knqe.eng.rdu2.dc.redhat.com/temp/Makefile
wget -nv -O /home/PURPOSE http://netqe-infra01.knqe.eng.rdu2.dc.redhat.com/temp/PURPOSE

export vm_image_name="rhel7.2.qcow2"
export vm_xml_file="vm_rhel72.xml"

# run test
cd /home && make run

