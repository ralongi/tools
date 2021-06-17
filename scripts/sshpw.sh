#!/bin/bash

# This script will attempt to SSH to target host by iterating through list of common passwords provided in a file.
# Note that this is obviously NOT a secure tool.  This tool is to be used only for systems in the lab where security is not a concern.

dbg_flag=${dbg_flag:-"set +x"}
$dbg_flag
rhel_version=$(cut -f1 -d. /etc/redhat-release | sed 's/[^0-9]//g')

source ~/.bashrc

target=$1
if [[ $# -lt 1 ]]; then
	echo ""
	echo "Please provide a valid host name or IP address."
	echo "Example: $0 netqe20.knqe.lab.eng.bos.redhat.com"
	echo "Example: $0 10.19.15.71"
	echo ""
	exit 1
fi

if [[ $(echo $target | awk -F "." '{print NF}') -eq 1 ]]; then
	if [[ $(fqdn $target) ]]; then
		target=$(fqdn $target)
	else
		target=$target.knqe.lab.eng.bos.redhat.com
	fi
fi

echo Target system is: $target

# install necessary packages
if [[ ! $(which sshpass) ]]; then
	if ! rpm -q epel-release > /dev/null; then	
		echo "Installing EPEL repo and sshpass package..."
		timeout 120s bash -c "until ping -c3 dl.fedoraproject.org; do sleep 10; done"
		yum -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-$rhel_version.noarch.rpm
		yum -y install sshpass
	fi
fi

if [[ ! $(which nslookup) ]]; then	
	if ! rpm -q bind-utils > /dev/null; then	
		echo "Installing bind-utils package..."
		yum -y install bind-utils
	fi
fi

if ! nslookup $target > /dev/null; then
	echo ""
	echo "$target does not appear to be a valid FQDN host name or IP address."
	echo "Please provide a valid host name or IP address."
	echo "Example: $0 netqe20.knqe.lab.eng.bos.redhat.com"
	echo "Example: $0 10.19.15.71"
	echo ""
	exit 1
fi

timeout 3s bash -c "until ping -c2 $target > /dev/null; do sleep 0; done"
if [[ $? -ne 0 ]]; then
	echo "$target is not responding.  Exiting..."
	exit 1
fi

#ssh -q root@$target exit
#if [[ $? -eq 0 ]]; then
#	echo "You already have an SSH key on $target.  Using standard SSH to connect..."
#	ssh -o StrictHostKeyChecking=no root@$target
#	exit 0
#fi

pw_file="./password_list.txt"

rm -f $pw_file

cat <<-EOF > $pw_file
	QwAo2U6GRxyNPKiZaOCx
	100yard-
	redhat
	fo0m4nchU
	qum5net
EOF

total_pw=$(cat $pw_file | wc -l)
count=1

echo "There are $total_pw passwords present in the password list file"

while [ $count -le $total_pw ]; do
	password=$(head -"$count"  $pw_file | tail -1)
	echo "Using password $password from password list file..."
	sshpass -p $password ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -q root@$target exit
	if [[ $? -eq 0 ]]; then
		echo "SSH successful using password $password"
		echo ""
		sshpass -p $password ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -q root@$target
		rm -f $pw_file
		exit
	else
		let count++
	fi
done

sshpass -p $password ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -q root@$target
	
if [[ $? -ne 0 ]]; then
	echo ""
	echo "Sorry.  None of the passwords provided worked."
	echo ""
fi

rm -f $pw_file
