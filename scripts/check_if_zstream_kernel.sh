#!/bin/bash

$dbg_flag

if [[ $# -lt 1 ]]; then
	echo "Please provide a kernel version"
	echo "Example: $0 5.14.0-284.117.1.el9_2 (you must include the 'el' designation)"
	exit 0
fi

kernel_raw=$1
arch=$2
if [[ $# -lt 2 ]]; then arch="x86_64"; fi
kernel_base=$(echo $kernel_raw | awk -F 'el' '{print $NF}' | awk -F '.' '{print $1}' | tr -d _)
kernel_base=$kernel_base"z"
yaml_file=~/ZConfig.yaml

wget -q -O $yaml_file https://gitlab.cee.redhat.com/kernel-qe/core-kernel/kernel-general/-/raw/master/Sustaining/ZConfig.yaml

check_if_zstream_kernel()
{
    $dbg_flag
	variant=baseos
    
    if [[ $(grep $kernel_base $yaml_file | grep -E -v 'x86_64') ]]; then
	    kernel=$(grep $kernel_base -A30 $yaml_file | grep -E -v 'x86_64' | grep version -A1 | grep kernel | grep -v rt | tr -d " ")
	    if [[ ${kernel_base::1} -lt 8 ]]; then
		    z_stream_repo_url=$(grep -A35 -w "$kernel_base" $yaml_file | grep "$arch" | grep -i $variant | awk '{print $2}' | tr -d "'")
	    else	
		    z_stream_repo_url=$(grep -A35 -w "$kernel_base" $yaml_file | grep "$arch" | grep -i $variant | awk '{print $3}' | head -n1)
	    fi
	    
	    if [[ $(echo $z_stream_repo_url | awk '{print substr($0,length($0),1)}') != "/" ]]; then
	        z_stream_repo_url=$z_stream_repo_url"/"
	    fi
		
	else
		echo "$kernel_base does not appear to have a Z stream"
	fi
	
	if [[ $(curl -sL "$z_stream_repo_url"Packages/k/ | grep $kernel_raw) ]]; then
		echo "$kernel_raw appears to be (or has been) a Z stream kernel"
	else
		echo "$kernel_raw does NOT appear to have been a Z stream kernel"
	fi
}

check_if_zstream_kernel
