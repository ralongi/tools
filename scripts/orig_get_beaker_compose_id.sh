#!/bin/bash
# Script to report the latest stable compose ID and associated kernel for the minor RHEL version provided by the user

dbg_flag=${dbg_flag:-"set +x"}
$dbg_flag

rhel_minor_ver=$1
rhel_major_ver=$(echo $rhel_minor_ver | awk -F "." '{print $1}')
if [[ $(echo $rhel_minor_ver | awk -F "." '{print $1}') == "8" ]]; then
	rhel_minor_ver=$rhel_minor_ver".0"
fi

display_usage()
{
	echo "This script will report the latest stable compose available for the RHEL version provided."
	echo "Usage: $0 <target RHEL version>"
	echo "Example: $0 8.1"
	exit 0
}

if [[ $# -lt 1 ]] || [[ $1 = "-h" ]] || [[ $1 = "--help" ]]	|| [[ $1 = "-?" ]]; then
	display_usage
fi

view_id=$(curl -sL https://beaker.engineering.redhat.com/distrotrees/?simplesearch=rhel-$rhel_minor_ver | grep '/distros/view' | grep -v '.n' | head -n1 | awk -F ">" '{print $1}' | awk -F "=" '{print $NF}' | tr -d '"')
distro_id=$(curl -sL https://beaker.engineering.redhat.com/distros/view?id="$view_id" | grep distro_tree_id | head -n1 | awk -F "=" '{print $3}' | awk '{print $1}' | tr -d '"')
latest_compose_id=$(curl -sL https://beaker.engineering.redhat.com/distrotrees/?simplesearch=rhel-$rhel_minor_ver | grep '/distros/view' | grep -v '.n' | head -n1 | awk -F ">" '{print $2}' | awk -F "<" '{print $1}')
build_url=$(curl -sL https://beaker.engineering.redhat.com/distrotrees/$distro_id#lab-controllers | grep "http://download.eng.bos.redhat.com" | grep -v href | tr -d " ")
arch=$(echo $build_url | awk -F "/os" '{print $1}' | awk -F "/" '{print $NF}')
#el_ver=$(echo "el$rhel_major_ver")
kernel_id=$(curl -sL "$build_url"Packages | egrep kernel-[0-9] | head -n1 | awk -F ">" '{print $2}' | awk -F "=" '{print $NF}' | tr -d '"')
echo $kernel_id > ~/kernel_id.tmp
kernel_id=$(sed "s/.$arch.rpm//g" ~/kernel_id.tmp)
rm -f ~/kernel_id.tmp
echo ""
echo "The latest stable RHEL $rhel_minor_ver compose available in beaker is: $latest_compose_id"
echo "The kernel associated with compose $latest_compose_id is: $kernel_id"
echo ""

