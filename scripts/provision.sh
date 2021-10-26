#!/bin/bash
dbg_flag=${dbg_flag:-"set +x"}
$dbg_flag

# to provision a system using the bkr cli

display_usage()
{
	echo "This script will provision a system based on the system name and compose provided."
	echo "Usage: $0 <system> <distro_name>"
	echo "Example: $0 netqe9.knqe.lab.eng.bos.redhat.com RHEL-8.3"
	exit 0
}

if [[ $# -lt 2 ]] || [[ $1 = "-h" ]] || [[ $1 = "--help" ]]	|| [[ $1 = "-?" ]]; then
	display_usage
fi

system_name=$1
distro=$2

get_beaker_compose_id()
{
	dbg_flag=${dbg_flag:-"set +x"}
	$dbg_flag

	rhel_minor_ver=$1
	rhel_major_ver=$(echo $rhel_minor_ver | awk -F "." '{print $1}')
	if [[ $(echo $rhel_minor_ver | awk -F "." '{print $1}') == "8" ]]; then
		rhel_minor_ver=$rhel_minor_ver".0"
	fi

	view_id=$(curl -sL https://beaker.engineering.redhat.com/distrotrees/?simplesearch=rhel-$rhel_minor_ver | grep '/distros/view' | grep -v '.n' | head -n1 | awk -F ">" '{print $1}' | awk -F "=" '{print $NF}' | tr -d '"')
	distro_id=$(curl -sL https://beaker.engineering.redhat.com/distros/view?id="$view_id" | grep distro_tree_id | head -n1 | awk -F "=" '{print $3}' | awk '{print $1}' | tr -d '"')
	latest_compose_id=$(curl -sL https://beaker.engineering.redhat.com/distrotrees/?simplesearch=rhel-$rhel_minor_ver | grep '/distros/view' | grep -v '.n' | head -n1 | awk -F ">" '{print $2}' | awk -F "<" '{print $1}')
	build_url=$(curl -sL https://beaker.engineering.redhat.com/distrotrees/$distro_id#lab-controllers | grep "http://download.eng.bos.redhat.com" | grep -v href | tr -d " ")
	arch=$(echo $build_url | awk -F "/os" '{print $1}' | awk -F "/" '{print $NF}')
	kernel_id=$(curl -sL "$build_url"Packages | egrep kernel-[0-9] | head -n1 | awk -F ">" '{print $2}' | awk -F "=" '{print $NF}' | tr -d '"')
	echo $kernel_id > ~/kernel_id.tmp
	kernel_id=$(sed "s/.$arch.rpm//g" ~/kernel_id.tmp)
	rm -f ~/kernel_id.tmp
	echo ""
	echo "The latest stable RHEL $rhel_minor_ver compose available in beaker is: $latest_compose_id"
	echo "The kernel associated with compose $latest_compose_id is: $kernel_id"
	echo ""
}

if [[ ! $(echo $distro | grep -i RHEL) ]]; then
	get_beaker_compose_id $distro > /tmp/distro.txt
	distro=$(grep 'latest stable' /tmp/distro.txt | awk -F ":" '{print $NF}' | tr -d " ")
	rm -f /tmp/distro.txt
fi	

distro_ver=$(echo $distro | awk -F "-" '{print $2}' | awk -F "." '{print $1}')

if [[ $(echo $distro_ver -ge 8) ]]; then
	variant="BaseOS"
else
	variant="Server"
fi

arch=$3
if [[ $# -lt 3 ]]; then arch="x86_64"; fi

distro_id=$(bkr distro-trees-list --name=$distro --arch=$arch | grep -B2 "Variant: $variant" | grep ID | awk '{print $NF}')

echo "Provisioning $system_name with distro $distro (Distro ID: $distro_id)"

bkr system-reserve $system_name 2>/dev/null
bkr system-provision --distro-tree=$distro_id $system_name

