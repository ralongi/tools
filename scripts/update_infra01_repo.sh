#!/bin/bash

update_infra01_repo()
{
	ovs_target=$1
	file_server="netqe-infra01.knqe.lab.eng.bos.redhat.com"

	if [[ $ovs_target == "2.4.1" ]]; then
		ovs_target="openvswitch-2.4.1-1.git20160628.el7fdp.x86_64.rpm"
		ovs_rpm_location="2.4.1/1.git20160628.el7fdp"
	elif [[ $ovs_target == "2.5.0.14" ]]; then
		ovs_target="openvswitch-2.5.0-14.git20160727.el7fdp.x86_64.rpm"
		ovs_rpm_location="2.5.0/14.git20160727.el7fdp"
	elif [[ $ovs_target == "2.5.0.22" ]]; then
		ovs_target="openvswitch-2.5.0-22.git20160727.el7fdp.x86_64.rpm"
		ovs_rpm_location="2.5.0/22.git20160727.el7fdp"
	elif [[ $ovs_target == "2.5.0.23" ]]; then
		ovs_target="openvswitch-2.5.0-23.git20160727.el7fdb.x86_64.rpm"
		ovs_rpm_location="2.5.0/23.git20160727.el7fdb"
	elif [[ $ovs_target == "2.6.1" ]]; then
		ovs_target="openvswitch-2.6.1-3.git20161206.el7fdb.x86_64.rpm"
		ovs_rpm_location="2.6.1/3.git20161206.el7fdb"
	else
		echo "No valid OVS target version was specified."
	fi

	ssh root@$file_server "rm -f /home/www/html/repo/packages/openvswitch*.rpm && wget -q -O /home/www/html/repo/packages/$ovs_target http://download-node-02.eng.bos.redhat.com/brewroot/packages/openvswitch/$ovs_rpm_location/x86_64/$ovs_target && createrepo --update /home/www/html/repo/"

	yum clean all expire-cache
	yum provides openvswitch
}

change_ovs()
{
	yum -y remove openvswitch
	yum -y install openvswitch
	current_ovs_ver=$(rpm -q openvswitch)".rpm"
	if [[ $current_ovs_ver == $ovs_target ]]; then
		echo "OVS version change was successful.  Test PASSED"
	else
		echo "OVS version change was unsuccessful.  Test FAILED."
	fi
}






