#!/bin/bash

target_dir=$1

if [[ $# -lt 1 ]]; then echo "Please specify the target directory to be tagged ($0 <target_dir>"; exit 1; fi

pushd /home/ralongi/git/kernel/networking/$target_dir
if [[ $? -eq 0 ]]; then echo "cd command PASSED"; else echo "cd command failed"; exit 1; fi

make tag > /tmp/bkrtag.tmp
if [[ $? -eq 0 ]]; then 
	echo "make tag command PASSED"; 
else 
	if [[ $(grep 'is not an ancestor of HEAD' /tmp/bkrtag.tmp) ]]; then
		tag=$(grep 'current tag' /tmp/bkrtag.tmp | awk '{print $4}')
		echo "Got an error that $tag is not an ancestor of HEAD.  Trying to merge it now..."
		git merge -m "" $tag HEAD
		sleep 2
		make tag > /tmp/bkrtag.tmp
		if [[ $? -eq 0 ]]; then
			echo "make tag command PASSED";
		else
			echo "make tag command failed again"
			exit 1
		fi
	else
		echo "make tag command failed"
		exit 1
	fi
fi	

tag=$(grep -i tagging /tmp/bkrtag.tmp | awk '{ print $4 }')

echo $tag
git push origin $tag
if [[ $? -eq 0 ]]; then echo "git push command PASSED"; else echo "git push command failed"; exit 1; fi

make bkradd
if [[ $? -eq 0 ]]; then echo "make bkradd command PASSED"; else echo "make bkradd command failed"; exit 1; fi
popd
