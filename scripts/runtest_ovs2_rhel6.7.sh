# Script to set up environment for BOS lab and kick of test (/home/ralongi/Documents/scripts/runtest_ovs1.sh)

#!/bin/bash

sshpass -p redhat ssh root@qe-dell-ovs1.knqe.lab.eng.bos.redhat.com << "EOF"
	# the host still has the old hostname
	export HOSTNAME=qe-dell-ovs1.knqe.lab.eng.bos.redhat.com

	# install beaker-client.repo
	wget -O /etc/yum.repos.d/beaker-client.repo http://download.lab.bos.redhat.com/beakerrepos/beaker-client-RedHatEnterpriseLinux.repo

	# install beaker related packages
	yum install -y rhts-test-env beakerlib rhts-devel rhts-python beakerlib-redhat beaker-client beaker-redhat

	# export BOS specific variables to be used for the test
	export CLIENTS=qe-dell-ovs1.knqe.lab.eng.bos.redhat.com
	export SERVERS=qe-dell-ovs3.knqe.lab.eng.bos.redhat.com
	export NIC_DRIVER=bnx2x
	export NAY=no
	export PVT=yes
	export vm_os_variant=rhel7
	export image_name=rhel7.1.qcow2
	export img_vm=http://pnate-control-01.lab.bos.redhat.com/rhel7.1.qcow2
	export JOBID=778245

	# create beaker-tasks.repo file
	(
		echo [beaker-tasks]
		echo name=beaker-tasks
		echo baseurl=http://beaker.engineering.redhat.com/rpms
		echo enabled=1
		echo gpgcheck=0
		echo skip_if_unavailable=1
	) > /etc/yum.repos.d/beaker-tasks.repo

	# download the ovs test cases
	yum -y install kernel-kernel-networking-openvswitch-tests

	# run all tests except for ovs_bond
	export OVS_TOPO=""

	# run all tests including ovs_bond
	#export OVS_TOPO="ovs_all"

	# run certain cases
	#export OVS_TOPO="ovs_nic ovs_vlan_nic"

	# only setup test environment but do not run test
	#export OVS_TOPO="setup"

	# kick off test
	cd /mnt/tests/kernel/networking/openvswitch/tests; make run
EOF

