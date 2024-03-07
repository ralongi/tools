#!/bin/bash

$dbg_flag

target=$1
if [[ $# -lt 1 ]]; then
	echo ""
	echo "Please provide a valid host name or IP address."
	echo "Example: $0 netqe44.knqe.lab.eng.bos.redhat.com"
	echo "Example: $0 10.19.15.71"
	echo ""
	exit 1
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
	echo "Example: $0 netqe44.knqe.lab.eng.bos.redhat.com"
	echo "Example: $0 10.19.15.71"
	echo ""
	exit 1
fi

timeout 3s bash -c "until ping -c2 $target > /dev/null; do sleep 0; done"
if [[ $? -ne 0 ]]; then
	echo "$target is not responding.  Exiting..."
	exit 1
fi

pw_file=~/.ssh_pw.txt
rm -f "$pw_file"
cat <<-EOF > "$pw_file"
	QwAo2U6GRxyNPKiZaOCx
	100yard-
	fo0m4nchU
	redhat
	qum5net
EOF

pw_file=~/.ssh_pw.txt
target=$1

timeout 5s bash -c "until ssh -q root@$target exit > /dev/null; do sleep 0; done"
if [[ $? -eq 0 ]]; then
	echo "SSH key already exists on $target and ssh is successful."
	exit 0
fi

total_pw=$(cat "$pw_file" | wc -l)
count=1

echo "There are $total_pw passwords present in the password list file"
echo ""
echo "Trying to copy ssh key to $target using passwords provided and verifying that ssh is then successful..."
echo ""
IFS=$'\n'
while [[ $count -le $total_pw ]]; do
    for next in $(cat "$pw_file"); do
        echo "Trying password $next ..."
        sshpass -p $next ssh-copy-id -o "StrictHostKeyChecking no" -i ~/.ssh/id_rsa.pub root@$target >/dev/null 2>&1
        wait
        sleep 3
        timeout 5s bash -c "until ssh -q -o 'StrictHostKeyChecking no' root@$target exit > /dev/null; do sleep 0; done"
        if [[ $? -eq 0 ]]; then
	        echo "SSH key has been successfully copied to $target and ssh is successful."
	        exit 0
	    else
	        let count++
        fi
    done
done
echo "None of the passwords provided worked."
