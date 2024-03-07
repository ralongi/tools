#!/bin/bash

dbg_flag=${dbg_flag:-"set +x"}
$dbg_flag

# Script to log into target host and gather iface and driver info

. ~/.bashrc

fq()
{
    $dbg_flag
    target=$1;
    fqdn=$(alias $target 2> /dev/null | awk '{print $NF}' | awk -F "@" '{print $NF}' | tr -d "'");
    echo $fqdn
}

user=${user:-"root"}
target=$1
if [[ ! $(echo $target | grep 'redhat.com') ]]; then
    target=$(fq $target)
fi
password=$2
default_password="QwAo2U6GRxyNPKiZaOCx"
timeout=${timeout:-"5s"}

if [[ $# -lt 1 ]]; then
	echo "You must specify a target host and root password ($0 <target_host> [root pw])."
	echo "Password QwAo2U6GRxyNPKiZaOCx will be used if no password is provided"
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

nslookup $target > /dev/null
if [[ $? -ne 0 ]]; then
	target=$(grep "alias $target" ~/.bashrc 2> /dev/null | awk '{print $NF}' | awk -F "@" '{print $NF}' | tr -d "'")
	nslookup $target > /dev/null
	if [[ $? -ne 0 ]]; then
		echo "$target does not appear to be a valid FQDN.  Please enter a valid FQDN target."
		exit 0
	fi
fi

#timeout $timeout bash -c "until traceroute $target > /dev/null; do sleep 1s; done"
echo "Checking connectivity to $target..."
timeout $timeout bash -c "until ping -c1 $target > /dev/null; do sleep 1s; done"
if [[ $? -ne 0 ]]; then
	echo "$target is not reachable.  Exiting test..."
	exit
fi

echo "Logging into $target..."
cat /home/ralongi/github/tools/nic_info_tool/get_nic_info.sh | sshpass -p $password ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -q $user@$target 'bash -'

