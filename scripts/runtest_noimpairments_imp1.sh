# Script to set up environment for BOS lab and kick of test (/home/ralongi/Documents/scripts/runtest_imp1.sh)

#!/bin/bash

sshpass -p redhat ssh root@impairment1.knqe.lab.eng.bos.redhat.com << "EOF"

	# install beaker-client.repo
	wget -O /etc/yum.repos.d/beaker-client.repo http://download.lab.bos.redhat.com/beakerrepos/beaker-client-RedHatEnterpriseLinux.repo

	# install beaker related packages
	yum install -y rhts-test-env beakerlib rhts-devel rhts-python beakerlib-redhat beaker-client beaker-redhat

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
		if rpm -q git 2>/dev/null; then
			cd /mnt/tests/kernel; git pull; echo "Git is already installed."
			return 0
		fi

        	yum -y install git
        	mkdir /mnt/tests
		cd /mnt/tests
        	git clone git://pkgs.devel.redhat.com/tests/kernel
}
	git_install

	# kick off test
	cd /mnt/tests/kernel/networking/impairment/tests/no_impairments; make run
EOF

