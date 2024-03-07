#!/bin/bash

$dbg_flag

if [[ $# -lt 1 ]]; then
	echo "Please provide a RHEL version"
	echo "Example: $0 8.6"
	exit 0
fi

zstream_raw=$1
arch=$2
if [[ $# -lt 2 ]]; then arch="x86_64"; fi

get_kernel_from_compose()
{
	dbg_flag=${dbg_flag:-"set +x"}
	$dbg_flag

	# to obtain the kernel package contained in a given compose
	compose_id=$1

	if [[ $(echo $compose_id | awk -F "." '{print $1}' | awk -F "-" '{print $NF}') -ge 8 ]]; then
		variant="BaseOS"
	else
		variant="Server"
	fi

	distro_id=$(bkr distro-trees-list --name=$compose_id --arch=$arch | grep -B2 "Variant: $variant" | grep ID | awk '{print $NF}')
	if [[ -z $distro_id ]]; then return 1; fi

	build_url=$(curl -sL https://beaker.engineering.redhat.com/distrotrees/$distro_id#lab-controllers | grep -A 12 bos.redhat.com | grep http | grep -v href | tr -d " ")

	kernel_id=$(curl -sL "$build_url"Packages | egrep 'kernel-[0-9]' | head -n1 | awk '{print $6}' | awk -F '"' '{print $2}')
	kernel_id_short=$(echo $kernel_id | awk -F ".$arch" '{print $1}')
}

get_zstream_compose()
{
	# Search for valid compose containing z stream kernel (make 10 attempts)
	if [[ -z $zstream_date_integer ]]; then
		zstream_date_integer=$(echo $zstream_kernel_date | tr -d '-' | bc)
	fi
	count=0
	while [ $count -lt 10 ]; do
		zstream_compose=$(curl -sL https://beaker.engineering.redhat.com/distros/?simplesearch=rhel-$zstream_raw | grep RHEL | grep view | grep -w $zstream_date_integer | awk -F '>' '{print $2}' | awk -F '<' '{print $1}' | grep -v '\.d')
		if [[ -z $zstream_compose ]]; then
			let zstream_date_integer++
			let count++
		else
			#echo "Z stream compose is: $zstream_compose"
			break
		fi
	done
}

echo ""
echo "Gathering information on the current Z stream kernel and compose for $1 ($arch)..."

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

echo "Searching for a valid compose to use for $1 Z stream..."

if [[ $zstream_kernel ]]; then
	f=$(echo $zstream_kernel | awk -F'.' '{print $NF}')
	zstream_kernel_tmp=$(echo $zstream_kernel | sed "s/.$f//") 
	
	if [[ "$zstream_kernel_tmp" == "$kernel" ]]; then
		zstream_kernel=$(curl -sL "$z_stream_repo_url"/Packages/k/ | grep $kernel | tail -n2 | head -n1 | awk -F 'href=' '{print $2}' | awk -F '"' '{print $2}' | awk -F ".$arch" '{print $1}')
		zstream_kernel_date=$(curl -sL "$z_stream_repo_url"Packages/k/ | grep $kernel | tail -n2 | head -n1 | awk -F 'href=' '{print $2}' | awk -F '"right">' '{print $2}' | awk '{print $1}')
	fi

	get_zstream_compose > /dev/null

	if [[ -z $zstream_compose ]]; then
		echo "Could not identify a compose that has the necessary Z stream kernel."
		echo ""
		exit 1
	else
		get_kernel_from_compose $zstream_compose > /dev/null
		while [ -z $build_url ]; do
			let zstream_date_integer++
			get_zstream_compose
			get_kernel_from_compose $zstream_compose > /dev/null
			
			echo "line 141 arch is $arch"
			
		done
			
		echo ""
		if [[ $(echo $kernel_id | awk -F ".$arch" '{print $1}') == $zstream_kernel ]]; then
			echo "A valid Z stream compose has been identified: $zstream_compose"
			echo "The current publicly available Z stream kernel for $1 ($arch) is: $zstream_kernel (dated $zstream_kernel_date)"
			#echo "The compose for this Z stream is: $zstream_compose"
			echo ""
		else
			echo "$zstream_kernel is not present in compose $zstream_compose"
			exit 1
		fi
	fi

else
	echo "There is no Z stream kernel available for $1 for $arch"
fi
