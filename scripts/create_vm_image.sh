#!/bin/bash

# usage: ./vm_image.sh

# if using a specific compose, first execute: export COMPOSE=<target compose id" in terminal window where you are executing this script

dbg_flag=${dbg_flag:-"set +x"}
$dbg_flag

skip_upload=${skip_upload:-"yes"}

echo "Please provide the FQDN (hostname) of the target system (For example,netqe9.knqe.lab.eng.bos.redhat.com):"
read target_system

if [[ -z $COMPOSE ]]; then
	echo "Please provide the target RHEL minor version for the target system (For example, 8.5):"
	read RHEL_VER
	/home/ralongi/inf_ralongi/scripts/get_beaker_compose_id.sh $RHEL_VER && export COMPOSE=$(/home/ralongi/gvar/bin/gvar $latest_compose_id | awk -F "=" '{print $NF}')
else
	echo "You have specified compose $COMPOSE for use"
	export COMPOSE=$(/home/ralongi/gvar/bin/gvar $COMPOSE)
fi

echo "Provisioning $target_system with compose $COMPOSE"

# Provison target system
/home/ralongi/github/tools/scripts/provision.sh $target_system $COMPOSE
total_sleep=20
echo "Sleeping $total_sleep minutes while system is being provisioned..."
count=1

while [[ $count -le $total_sleep ]]; do
	sleep 1m
	echo "Time remaining: $((( $total_sleep - $count ))) minutes"
	let count++
done

# Test SSH to target system
while [ 1 ]; do
	ssh -q -o "StrictHostKeyChecking no" root@$target_system exit
	if [[ $? -ne 0 ]]; then
		echo "SSH to $target_system was unsuccessful.  Sleeping 2 minutes and will try again..."
		sleep 2m
	else
		echo "SSH to $target_system was successful."
		break
	fi
done

TERM=xterm sshpass -p 100yard- ssh -X -o UserKnownHostsFile=/dev/null -o "StrictHostKeyChecking=no" root@$target_system << 'EOF'

RHEL_VERSION=$(cat /etc/os-release | grep VERSION_ID | cut -d \" -f 2 | cut -d . -f 1)
if [[ $RHEL_VERSION -lt 8 ]]; then
	if [[ -s /etc/yum.repos.d/beaker-Server.repo ]]; then
		repo_file="/etc/yum.repos.d/beaker-Server.repo"
	elif [[ -s /etc/yum.repos.d/beaker-Client.repo ]]; then
		repo_file="/etc/yum.repos.d/beaker-Client.repo"
	fi
else
	repo_file="/etc/yum.repos.d/beaker-BaseOS.repo"
fi

yum -y install git
mkdir /root/git
pushd /root/git && git clone https://github.com/ctrautma/VSPerfBeakerInstall
chmod +x ./VSPerfBeakerInstall/vmcreate.sh
popd
MYCOMPOSE=$(cat $repo_file | grep baseurl | cut -c9-)
sudo sh -c 'echo 1 > /proc/sys/vm/overcommit_memory'
########## temporary workaround for problem with vmcreate.sh ##########
pushd /root/git/VSPerfBeakerInstall
git reset --hard d30ceb6555c68bc86499ffe30587fe2c006c259c
chmod +x ./vmcreate.sh
sleep 3
popd
#######################################################################
/root/git/VSPerfBeakerInstall/vmcreate.sh -d -c 3 -l $MYCOMPOSE
sleep 480
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
rlLog "Size of master.qcow2 image file that was created: $image_size"
if [ ! $(echo "$image_size" | grep G) ]; then
	echo "Guest image file size is only $image_size.  Printing out qemu master.log..."
	echo "Current time: $(date +'%D %r')"
	echo "qemu master.log file info: $(ls -lth /var/log/libvirt/qemu/master.log)"
	cat /var/log/libvirt/qemu/master.log
fi

source /etc/os-release
new_image_name=rhel"$VERSION_ID".qcow2
/bin/cp -f /var/lib/libvirt/images/master.qcow2 /var/lib/libvirt/images/$new_image_name

epel_install()
{
	local rhel_version=$(cut -f1 -d. /etc/redhat-release | sed 's/[^0-9]//g')
	local arch=$(uname -m)

	if rpm -q epel-release 2>/dev/null; then
		echo "EPEL repo is already installed"
		return 0
	elif [[ ! $(rpm -q https://dl.fedoraproject.org/pub/epel/epel-release-latest-$rhel_version.noarch.rpm) ]]; then
		rlLog "EPEL package https://dl.fedoraproject.org/pub/epel/epel-release-latest-$rhel_version.noarch.rpm is not available"
		rlLog "Skipping EPEL installation..."
		return 0
	else
		echo "Installing EPEL repo..."
		timeout 120s bash -c "until ping -c3 dl.fedoraproject.org; do sleep 10; done"
		yum -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-$rhel_version.noarch.rpm
	fi
}

epel_install
yum -y install sshpass

yes "y" | ssh-keygen -o -t ed25519 -f ~/.ssh/id_rsa -N ""
ssh -q -o "StrictHostKeyChecking no" root@netqe-infra01.knqe.lab.eng.bos.redhat.com exit
if [[ $? -ne 0 ]]; then 
    sshpass -p 100yard- ssh-copy-id -o "StrictHostKeyChecking no" -i ~/.ssh/id_rsa.pub root@netqe-infra01.knqe.lab.eng.bos.redhat.com
    wait
    sleep 3
fi

if [[ $skip_upload != "yes ]]; then
	ssh -o "StrictHostKeyChecking no" root@netqe-infra01.knqe.lab.eng.bos.redhat.com "ls /home/www/html/share/vms/OVS/$new_image_name"
	if [[ $? -ne 0 ]]; then
		echo "Uploading $new_image_name..."
		scp -o "StrictHostKeyChecking no" /var/lib/libvirt/images/$new_image_name root@netqe-infra01.knqe.lab.eng.bos.redhat.com:/home/www/html/share/vms/OVS/
	else
		echo "/home/www/html/share/vms/OVS/$new_image_name already exists on netqe-infra01.knqe.lab.eng.bos.redhat.com so skipping automatic file upload."
	fi
else
	echo "You have elected to skip upload of image file."
fi

exit
SCRIPT

EOF
