#!/bin/bash

# script to create a new qcow2 guest image based on the compose on the host system
# provision host system with target compose, then run this script on the host system
# once master image is created, copy it to infra01 (example for RHEL-8.3 image below)
# scp /var/lib/libvirt/images/master.qcow2 root@netqe-infra01.knqe.eng.rdu2.dc.redhat.com:/home/www/html/share/vms/OVS/rhel8.3.qcow2

RHEL_VERSION=$(cat /etc/os-release | grep VERSION_ID | cut -d \" -f 2 | cut -d . -f 1)
if [[ $RHEL_VERSION -eq 7 ]]; then
	if [[ -s /etc/yum.repos.d/beaker-Server.repo ]]; then
		repo_file="/etc/yum.repos.d/beaker-Server.repo"
	elif [[ -s /etc/yum.repos.d/beaker-Client.repo ]]; then
		repo_file="/etc/yum.repos.d/beaker-Client.repo"
	fi
elif [[ $RHEL_VERSION -eq 8 ]]; then
	repo_file="/etc/yum.repos.d/beaker-BaseOS.repo"
fi

yum -y install git
mkdir /root/git
pushd /root/git && git clone https://github.com/ctrautma/VSPerfBeakerInstall
chmod +x ./VSPerfBeakerInstall/vmcreate.sh
popd
MYCOMPOSE=$(cat $repo_file | grep baseurl | cut -c9-)
sudo sh -c 'echo 1 > /proc/sys/vm/overcommit_memory'
/root/git/VSPerfBeakerInstall/vmcreate.sh -c 3 -l $MYCOMPOSE
sleep 30
SECONDS=0
while [ $SECONDS -lt 1800 ]; do
	if [[ $(virsh list --all | grep master | awk '{print $NF}') != "off" ]]; then
		sleep 15
	else
		break
	fi
done
sleep 2m
image_size=$(ls -alth /var/lib/libvirt/images/master.qcow2 | awk '{print $5}')
echo "Size of master.qcow2 image file that was created: $image_size"

