#!/bin/bash

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
	pw=$(read $line ~/.ssh_pw.txt)
	sshpass -p $pw ssh-copy-id -o "StrictHostKeyChecking no" -i ~/.ssh/id_rsa.pub root@$host
	wait
	sleep 3
	ssh -q root@$host exit
	if [[ $? -eq 0 ]]; then
		echo "SSH key has been successfully copied to $host"
	else
		let line++
	fi
done

for i in $(cat ~/.ssh_pw.txt); do
	sshpass -p $i ssh-copy-id -o "StrictHostKeyChecking no" -i ~/.ssh/id_rsa.pub root@$host
	wait
	sleep 3
	ssh -q root@$host exit
	if [[ $? -eq 0 ]]; then
		ssh -o "StrictHostKeyChecking no" root@$host
		exit 0
	elif [[ $? -ne 0 ]]; then
		break
	fi
done

#for i in $(cat ~/.ssh_pw.txt); do
#	sshpass -p $i ssh -o StrictHostKeychecking=no root@$host
#done

#exit


