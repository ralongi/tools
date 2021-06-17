#!/bin/bash
dbg_flag=${dbg_flag:-"set +x"}
$dbg_flag

# to obtain the kernel package contained in a given compose

compose_id=$1

if [[ $(echo $compose_id | awk -F "." '{print $1}') == "RHEL-8" ]]; then
	variant="BaseOS"
else
	variant="Server"
fi

arch=$2
if [[ $# -lt 2 ]]; then arch="x86_64"; fi

if [[ $# -lt 1 ]]; then
	echo "Usage: $0 <compose> [arch]"
	echo "Example: $0 RHEL-7.9 [ppc64le]"
	exit 0
fi

distro_id=$(bkr distro-trees-list --name=$compose_id --arch=$arch | grep -B2 "Variant: $variant" | grep ID | awk '{print $NF}')

build_url=$(curl -sL https://beaker.engineering.redhat.com/distrotrees/$distro_id#lab-controllers | grep -A 12 rhts.eng.bos.redhat.com | grep http | grep -v href | tr -d " ")

kernel_id=$(curl -sL "$build_url"Packages | egrep kernel-[0-9] | head -n1 | awk -F ">" '{print $2}' | awk -F "=" '{print $NF}' | tr -d '"')
echo $kernel_id > ~/kernel_id.tmp
kernel_id=$(sed "s/.$arch.rpm//g" ~/kernel_id.tmp)
rm -f ~/kernel_id.tmp
echo ""
echo "The kernel associated with compose $compose_id is: $kernel_id"
echo ""

