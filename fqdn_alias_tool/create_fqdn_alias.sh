#!/bin/bash

# Script to log into target host and set up DNS/IP aliases
set -x

target=$1
password=$2
default_password="100yard-"

if [[ $# -lt 1 ]]; then
	echo "You must specify a target host and root password($0 <target_host> [root pw])."
	exit
fi

if [[ $# -lt 2 ]]; then
	password="$default_password"
fi

rhel_version=$(cut -f1 -d. /etc/redhat-release | sed 's/[^0-9]//g')
if [[ $rhel_version -eq 7 ]]; then
	sshpass_rpm="https://rpmfind.net/linux/epel/7/x86_64/Packages/s/sshpass-1.06-1.el7.x86_64.rpm"
elif [[ $rhel_version -eq 7 ]]; then
	sshpass_rpm="https://rpmfind.net/linux/epel/6/x86_64/Packages/s/sshpass-1.06-1.el6.x86_64.rpm"
fi

if [[ ! $(which sshpass) ]]; then
	echo "sshpass must be installed for this tool to work.  You may find the sshpass package for your system here:  $sshpass_rpm"
	exit
fi

timeout 5s bash -c "until ping -c3 $target; do sleep 1s; done"
if [[ $? -ne 0 ]]; then
	echo "$target is not reachable.  Exiting test..."
	exit
fi

cat ./alias_cfg.sh | sshpass -p $password ssh -o "StrictHostKeyChecking= no" root@$target 'bash -'

