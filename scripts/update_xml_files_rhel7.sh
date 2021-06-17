#!/bin/bash
# Script to report the latest compose ID and associated kernel for the major RHEL version provided by the user

dbg_flag=${dbg_flag:-"set +x"}
$dbg_flag

sedeasy ()
{
sed -i "s/$(echo $1 | sed -e 's/\([[\/.*]\|\]\)/\\&/g')/$(echo $2 | sed -e 's/[\/&]/\\&/g')/g" $3
}

rhel_ver=$1
if [[ $# -lt 1 ]]; then
	echo "Please provide a valid major RHEL version."
	echo "Usage $0 <Major RHEL version>"
	echo  "Example: $0 7"
	exit 0
fi

base_dir="/net/ntap-bos-c01-eng01-nfs01a.storage.bos.redhat.com/devops_engineering_nfs/devarchive/redhat/rel-eng"
ls "$base_dir"/latest-RHEL-"$rhel_ver"/compose/Server/x86_64/os/Packages/kernel* | awk -F "/" '{print $14}' > /tmp/results.txt
kernel=$(head -n1 /tmp/results.txt)
compose_id=$(cat "$base_dir"/latest-RHEL-"$rhel_ver"/COMPOSE_ID)

echo "******************************************************************************************"
echo "******************************************************************************************"
echo "The latest RHEL$rhel_ver compose ID is: $compose_id"
echo "The associated kernel is: $kernel"
echo "******************************************************************************************"
echo "******************************************************************************************"

for i in $(ls /home/ralongi/Documents/ovs_testing/xml_files/*rhel7.xml); do
	current_distro=$(grep distro_name $i | awk -F "value" '{print $2}' | tr -d '[="/>]' | awk '{print $1}')
	echo $current_distro > /tmp/current_distro.txt
	if [[ $(awk '{print NF}' /tmp/current_distro.txt) -gt 1 ]]; then current_distro=$(awk '{print $1}' /tmp/current_distro.txt); fi
	echo "File: $i"
	echo "Current distro: $current_distro"
	echo ""
	sed -i "s/$current_distro/$compose_id/g" $i
	new_distro=$(grep distro_name $i | awk -F "value" '{print $2}' | tr -d '[="/>]' | awk '{print $1}')
	echo "File: $i"
	echo "New distro: $new_distro"
	echo "=========================================================================================="
done

