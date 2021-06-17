#!/bin/bash

dbg_flag=${dbg_flag=:-"set +x"}
$dbg_flag

starting_compose=$1
ending_compose=$2
ovs_rpm_version=$3
selinux_setting=$4
test_type=$5

if [[ "$selinux_setting" == "disabled" ]]; then
	selinux_setting="no"
elif [[ "$selinux_setting" == "enabled" ]]; then
	selinux_setting="yes"
else
	echo "Please specify enabled or disabled for SELinux setting"
	exit 0
fi

if [[ $# -lt 5 ]]; then
	echo "You must provide four arguments: starting compose, ending compose, OVS version, selinux setting (enabled or disabled), test type (ovs or dpdk)"
	echo "Example: $0 RHEL-7.4-updates-20180228.0 RHEL-7.5 2.10.0 disabled dpdk"
	exit
fi

sedeasy ()
{
sed -i "s/$(echo $1 | sed -e 's/\([[\/.*]\|\]\)/\\&/g')/$(echo $2 | sed -e 's/[\/&]/\\&/g')/g" $3
}

if [[ "$test_type" == "ovs" ]]; then
	xml_file_list=${xml_file_list:-"template_upgrade_ovs_lp_to_lp.xml template_upgrade_ovs_lp_to_latest.xml"}
elif [[ "$test_type" == "dpdk" ]]; then
	xml_file_list=${xml_file_list:-"template_upgrade_dpdk_lp_to_lp.xml template_upgrade_dpdk_lp_to_latest.xml"}
else
	echo "Please specify ovs or dpdk for test type"
	exit 0
fi

while true; do
    read -p "Have you reviewed the template XML files for accuracy?" yn
    case $yn in
        [Yy]* ) pushd /home/ralongi/Documents/ovs_testing/xml_files || return;
				for file in $xml_file_list; do
					new_filename=$(echo $file | sed 's/template_//g')
					/bin/cp -f $file $new_filename;
					if [[ $(echo "$starting_compose" | awk -F "-" '{print $2}') == "7.3" ]]; then
						sedeasy '<param name="skip_test1" value="no"/>' '<param name="skip_test1" value="yes"/>' "$new_filename"
					fi
					sedeasy "starting_compose" "$starting_compose" "$new_filename";
					sedeasy "ending_compose" "$ending_compose" "$new_filename";
					for i in $(grep "SELinux Enabled:" "$new_filename"); do
						sedeasy "selinux_setting" "$selinux_setting" "$new_filename"
					done
					for i in $(grep selinux_enable "$new_filename"); do
						sedeasy "selinux_setting" "$selinux_setting" "$new_filename"
					done
					sedeasy "ovs_rpm_version_temp" "$ovs_rpm_version" "$new_filename"
					grep "ending_compose" "$new_filename";
					grep "$ending_compose" "$new_filename";					
					bkr job-submit "$new_filename"
				done
				popd;
        		exit;;
        [Nn]* ) exit;;
        * ) echo "Please answer yes or no.";;
    esac
done
exit

