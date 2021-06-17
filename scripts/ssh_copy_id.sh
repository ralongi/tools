#!/bin/bash

set -x

host=$1

if [[ $(echo $host | awk -F "." '{print NF}') -eq 1 ]]; then
	host=$1.knqe.lab.eng.bos.redhat.com
fi

if [[ $# -lt 1 ]]; then
	echo "Please provide a hostname"
	exit 1
fi

total_lines=$(cat ~/.ssh_pw.txt  | wc -l)
line=1

while [[ $line -le $total_lines ]]; do
	pw=$(tail -n+$line ~/.ssh_pw.txt | head -n1)
	echo "Password to be used is: $pw"
	sshpass -p $pw ssh-copy-id -o "StrictHostKeyChecking no" -i ~/.ssh/id_rsa.pub root@$host
	wait
	sleep 3
	ssh -q root@$host exit
	if [[ $? -eq 0 ]]; then
		echo "SSH key has been successfully copied to $host"
		exit 0
	else
		let line++
	fi
done
