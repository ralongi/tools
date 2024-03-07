#!/bin/bash

$dbg_flag
arch=${arch:-"x86_64"}

if [[ $# -lt 1 ]]; then
	echo "Please provide a RHEL version or COMPOSE"
	echo "Example: $0 RHEL-8.6.0"
	echo "Example: $0 8.6"
	exit 0
fi

if [[ $(echo $1 | grep RHEL) ]]; then
	z_stream_base=$(echo $1 | awk -F '-' '{print $2}' | tr -d . | cut -c-2)
else
	z_stream_base=$(echo $1 | tr -d . | cut -c-2)
fi
z_stream_base=$(echo $z_stream_base)z
pushd ~/temp > /dev/null
echo
wget -q -O ZConfig.yaml https://gitlab.cee.redhat.com/kernel-qe/core-kernel/kernel-general/-/raw/master/Sustaining/ZConfig.yaml

if [[ ${1::1} -lt 8 ]]; then
	variant=server
else
	variant=baseos
fi

if [[ $(grep $z_stream_base ZConfig.yaml) ]]; then
	kernel=$(grep $z_stream_base -A30 ZConfig.yaml  | grep version -A1 | grep kernel | grep -v rt | tr -d " ")
	if [[ ${1::1} -lt 8 ]]; then
		z_stream_repo_url=$(grep -A35 -w "$z_stream_base" ZConfig.yaml | grep "$arch" | grep -i $variant | awk '{print $2}' | tr -d "'")
	else	
		z_stream_repo_url=$(grep -A35 -w "$z_stream_base" ZConfig.yaml | grep "$arch" | grep -i $variant | awk '{print $3}' | head -n1)
	fi
	
	if [[ $(echo $z_stream_repo_url | awk '{print substr($0,length($0),1)}') == "/" ]]; then
		zstream_kernel=$(curl -sL "$z_stream_repo_url"Packages/k/ | grep $kernel | tail -n1 | awk -F 'href=' '{print $2}' | awk -F '"' '{print $2}' | awk -F ".$arch" '{print $1}')
		zstream_kernel_date=$(curl -sL "$z_stream_repo_url"Packages/k/ | grep $kernel | tail -n1 | awk -F 'href=' '{print $2}' | awk -F '"right">' '{print $2}' | awk '{print $1}')
	else
		zstream_kernel=$(curl -sL "$z_stream_repo_url"/Packages/k/ | grep $kernel | tail -n2 | head -n1 | awk -F 'href=' '{print $2}' | awk -F '"' '{print $2}' | awk -F ".$arch" '{print $1}')
		zstream_kernel_date=$(curl -sL "$z_stream_repo_url"Packages/k/ | grep $kernel | tail -n2 | head -n1 | awk -F 'href=' '{print $2}' | awk -F '"right">' '{print $2}' | awk '{print $1}')
	fi
fi

if [[ $zstream_kernel ]]; then
	f=$(echo $zstream_kernel | awk -F'.' '{print $NF}')
	zstream_kernel_tmp=$(echo $zstream_kernel | sed "s/.$f//") 
	
	if [[ "$zstream_kernel_tmp" == "$kernel" ]]; then
		zstream_kernel=$(curl -sL "$z_stream_repo_url"/Packages/k/ | grep $kernel | tail -n2 | head -n1 | awk -F 'href=' '{print $2}' | awk -F '"' '{print $2}' | awk -F ".$arch" '{print $1}')
		zstream_kernel_date=$(curl -sL "$z_stream_repo_url"Packages/k/ | grep $kernel | tail -n2 | head -n1 | awk -F 'href=' '{print $2}' | awk -F '"right">' '{print $2}' | awk '{print $1}')
	fi
	
	echo "The current publicly available Z stream kernel for $1 ($arch) is: $zstream_kernel (dated $zstream_kernel_date)"
else
	echo "There is no Z stream kernel available for $1 for $arch"
fi
echo
