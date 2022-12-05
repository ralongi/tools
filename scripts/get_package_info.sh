#!/bin/bash
# Script to report the latest stable compose ID and associated kernel for the minor RHEL version provided by the user

dbg_flag=${dbg_flag:-"set +x"}
$dbg_flag

display_usage()
{
	echo ""
	echo "This script will report the latest stable compose and associated kernel available for the RHEL minor version provided."
	echo "You may provide a specific valid compose ID instead of the general RHEL minor version."
	echo "You may optionally provide a single package string to query for package version information"
	echo ""
	echo "Usage: $0 <target RHEL version> [package string]"
	echo "Example: $0 8.4"
	echo "Example: $0 RHEL-8.4.0-updates-20211026.0"
	echo "Example: $0 8.5 ethtool"
	echo "Example: $0 RHEL-9.0.0-20220225.1 NetworkManager"
	echo ""
	exit 0
}

if [[ $# -lt 1 ]] || [[ $1 = "-h" ]] || [[ $1 = "--help" ]]	|| [[ $1 = "-?" ]]; then
	display_usage
fi

rhel_minor_ver=$1
rhel_major_ver=$(echo $rhel_minor_ver | awk -F "." '{print $1}')
#if [[ $(echo $rhel_minor_ver | awk -F "." '{print $1}') == "8" ]]; then
#	rhel_minor_ver=$rhel_minor_ver".0"
#fi

if [[ $(echo $rhel_minor_ver | grep -i RHEL) ]]; then
	compose_id=$rhel_minor_ver
	#distro_id=$(bkr distro-trees-list --name=$compose_id --arch=$arch | grep -B2 "Variant: $variant" | grep ID | awk '{print $NF}')
	distro_id=$(bkr distro-trees-list --name=$compose_id --arch=$arch | grep ID | awk '{print $NF}')
	build_url=$(curl -sL https://beaker.engineering.redhat.com/distrotrees/$distro_id#lab-controllers | grep -A 12 rhts.eng.bos.redhat.com | grep http | grep -v href | tr -d " ")
else
	view_id=$(curl -sL https://beaker.engineering.redhat.com/distrotrees/?simplesearch=rhel-$rhel_minor_ver | grep '/distros/view' | grep -v '\.n' | egrep -v '\.n|\.d' | head -n1 | awk -F ">" '{print $1}' | awk -F "=" '{print $NF}' | tr -d '"')
	distro_id=$(curl -sL https://beaker.engineering.redhat.com/distros/view?id="$view_id" | grep distro_tree_id | head -n1 | awk -F "=" '{print $3}' | awk '{print $1}' | tr -d '"')
	#distro_id=$(curl -sL https://beaker.engineering.redhat.com/distros/view?id="$view_id" | grep -A7 distrotrees | grep -A3 $arch | grep distro_tree_id | sed 's/[^0-9]*//g')
	export compose_id=$(curl -sL https://beaker.engineering.redhat.com/distrotrees/?simplesearch=rhel-$rhel_minor_ver | grep '/distros/view' | egrep -v '\.n|\.d' | grep -v '\.d' | head -n1 | awk -F ">" '{print $2}' | awk -F "<" '{print $1}')
	build_url=$(curl -sL https://beaker.engineering.redhat.com/distrotrees/$distro_id#lab-controllers | grep "http://download.eng.bos.redhat.com" | grep -v href | tr -d " ")
fi

#exit 0

package=$2

source ~/.bash_profile
gvar -v > /dev/null
if [[ $? -ne 0 ]]; then
	pushd ~
	git clone git@github.com:arturoherrero/gvar.git
	echo 'export PATH="${PATH}:~/gvar/bin"' >> ~/.bash_profile
	source ~/.bash_profile
	popd
fi
	
arch=$(echo $build_url | awk -F "/os" '{print $1}' | awk -F "/" '{print $NF}')
#el_ver=$(echo "el$rhel_major_ver")

#echo "build_url: $build_url"

if [[ $package ]]; then
	#package_list=$(curl -sL "$build_url"Packages | egrep $package | head -n1 | awk -F ">" '{print $2}' | awk -F "=" '{print $NF}' | tr -d '"')
	package_list=$(curl -sL "$build_url"Packages | egrep -w $package | head | awk -F ">" '{print $6}' | awk -F '"' '{print $2}')
fi

#curl -sL "$build_url"Packages | egrep NetworkManager-[0-9] | head | awk -F ">" '{print $2}' | awk -F "=" '{print $NF}' | tr -d '"'

kernel_id=$(curl -sL "$build_url"Packages | egrep -w kernel | head -n1 | awk -F ">" '{print $6}' | awk -F '"' '{print $2}')
echo $kernel_id > ~/kernel_id.tmp
kernel_id=$(sed "s/.$arch.rpm//g" ~/kernel_id.tmp)
rm -f ~/kernel_id.tmp
echo ""
if [[ ! $(echo $rhel_minor_ver | grep -i RHEL) ]]; then
	echo "The latest stable RHEL $rhel_minor_ver compose available in beaker is: $compose_id"
fi
echo "The kernel associated with compose $compose_id is: $kernel_id"
echo ""
if [[ $package ]]; then 
	echo "$package package list query results for compose $compose_id:"
	echo ""
	echo "$package_list"
	echo ""
fi
gvar compose_id=$latest_compose_id

