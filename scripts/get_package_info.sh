#!/bin/bash
# Script to report the latest stable compose ID and associated kernel for the minor RHEL version provided by the user
# You may optionally provide a single package string to query for package version information
# The default arch is x86_64.  To query for a different arch, first execute "export arch=<arch>" in the terminal window

dbg_flag=${dbg_flag:-"set +x"}
$dbg_flag
arch=${arch:-"x86_64"}

display_usage()
{
	echo ""
	echo "This script will report the latest stable compose and associated kernel available for the RHEL minor version provided."
	echo "You may provide a specific valid compose ID instead of the general RHEL minor version."
	echo "You may optionally provide a single package string to query for package version information"
	echo "The default arch is x86_64.  To query for a different arch, first execute: export arch=<arch> in the terminal window"
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

if [[ $(echo $rhel_minor_ver | grep -i RHEL) ]]; then
	compose_id=$rhel_minor_ver
	rhel_major_ver=$(echo $rhel_minor_ver | awk -F "." '{print $1}' | sed 's/RHEL-//g')
	distro_id=$(bkr distro-trees-list --name=$compose_id --arch=$arch | grep ID | awk '{print $NF}')
	build_url_baseos=$(curl -sL https://beaker.engineering.redhat.com/distrotrees/$distro_id#lab-controllers | grep "http://download.eng.rdu.redhat.com" | tail -1 | grep -v href | tr -d " " | tail -1)
else
	rhel_major_ver=$(echo $rhel_minor_ver | awk -F "." '{print $1}')
	view_id=$(curl -sL https://beaker.engineering.redhat.com/distrotrees/?simplesearch=rhel-$rhel_minor_ver | grep '/distros/view' | grep -v '\.n' | egrep -v '\.n|\.d' | head -n1 | awk -F ">" '{print $1}' | awk -F "=" '{print $NF}' | tr -d '"' | tail -1)
	distro_id=$(curl -sL https://beaker.engineering.redhat.com/distros/view?id="$view_id" | grep distro_tree_id | head -n1 | awk -F "=" '{print $3}' | awk '{print $1}' | tr -d '"' | tail -1)
	export compose_id=$(curl -sL https://beaker.engineering.redhat.com/distrotrees/?simplesearch=rhel-$rhel_minor_ver | grep '/distros/view' | egrep -v '\.n|\.d' | grep -v '\.d' | head -n1 | awk -F ">" '{print $2}' | awk -F "<" '{print $1}')
	build_url_baseos=$(curl -sL https://beaker.engineering.redhat.com/distrotrees/$distro_id#lab-controllers | grep "http://download.eng.rdu.redhat.com" | grep -v href | tr -d " " | tail -1)
fi

build_url_appstream=$(echo $build_url_baseos | sed 's/BaseOS/AppStream/g')

package=$2

arch=$(echo $build_url_baseos | awk -F "/os" '{print $1}' | awk -F "/" '{print $NF}')

if [[ $package ]]; then
	package_list=$(curl -sL "$build_url_baseos"Packages | egrep -wi $package | awk -F '>' '{print $3}' | awk -F '.rpm' '{print $1}')
	if [[ -z $package_list ]]; then
	    package_list=$(curl -sL "$build_url_appstream"Packages | egrep -wi $package | awk -F '>' '{print $3}' | awk -F '.rpm' '{print $1}')
	fi
fi

kernel_id=$(curl -sL "$build_url_baseos"Packages | egrep -w kernel | head -1 | awk -F '>' '{print $3}' | awk -F '.rpm' '{print $1}')
echo $kernel_id > ~/kernel_id.tmp
kernel_id=$(sed "s/.$arch.rpm//g" ~/kernel_id.tmp)
rm -f ~/kernel_id.tmp
echo ""
if [[ ! $(echo $rhel_minor_ver | grep -i RHEL) ]]; then
	echo "The latest stable RHEL $rhel_minor_ver compose available in beaker is: $compose_id"
fi
echo "The kernel associated with compose $compose_id is: $kernel_id"
echo ""
if [[ $package_list ]]; then 
	echo "$package package list query results for compose $compose_id:"
	echo ""
	echo "$package_list"
	echo ""
else
    echo "$package was not found in the list of packages for compose $compose_id" 
fi
