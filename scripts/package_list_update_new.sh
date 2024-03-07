#! /bin/bash

dbg_flag=${dbg_flag:-"set +x"}
$dbg_flag
checkin_git=${checkin_git:-"no"}
fdp_release=$1
if [[ $# -lt 1 ]]; then echo "Please provide FDP release (21I, 21j, etc):"; read fdp_release; fi
fdp_release=$(echo "$fdp_release" | awk '{print toupper($0)}')
new_package_template_file="/home/ralongi/github/tools/scripts/new_package_list_template.sh"
new_package_list_temp_file="/home/ralongi/temp/new_package_list_temp.sh"
new_package_list_file="/home/ralongi/temp/new_package_list.sh"

sedeasy ()
{
sed -i "s/$(echo $1 | sed -e 's/\([[\/.*]\|\]\)/\\&/g')/$(echo $2 | sed -e 's/[\/&]/\\&/g')/g" $3
}

rm -f $new_package_list_temp_file $new_package_list_file
/bin/cp -f "$new_package_template_file" "$new_package_list_temp_file"
sedeasy "fdp_release" "$fdp_release" "$new_package_list_temp_file"
echo "" >> $new_package_list_file
echo "# FDP $fdp_release Packages" >> $new_package_list_file

echo "Enter OVS SELinux RHEL-7 Version for FDP $fdp_release (18, etc.): "
read version
sedeasy "ovs_selinux_rhel7_ver" "$version" "$new_package_list_temp_file"
source "$new_package_list_temp_file"
http_code=$(curl --silent --head --write-out '%{http_code}' "$OVS_SELINUX_RHEL7" | grep HTTP | awk '{print $2}')
if [[ "$http_code" -ne 200 ]]; then echo "$OVS_SELINUX_RHEL7 is NOT a valid link.  Exiting..."; exit 1; fi
echo "OVS_SELINUX_$fdp_release"_RHEL7= >> $new_package_list_file
sed -i "s@^OVS_SELINUX_$fdp_release"_"RHEL7=@OVS_SELINUX_$fdp_release"_"RHEL7=${OVS_SELINUX_RHEL7}@g" $new_package_list_file
echo ""
echo "Package location: $OVS_SELINUX_RHEL7"
echo ""

echo "Enter OVS SELinux RHEL-8 Version for FDP $fdp_release (28, etc.): "
read version
sedeasy "ovs_selinux_rhel8_ver" "$version" "$new_package_list_temp_file"
source "$new_package_list_temp_file"
http_code=$(curl --silent --head --write-out '%{http_code}' "$OVS_SELINUX_RHEL8" | grep HTTP | awk '{print $2}')
if [[ "$http_code" -ne 200 ]]; then echo "$OVS_SELINUX_RHEL8 is NOT a valid link.  Exiting..."; exit 1; fi
echo "OVS_SELINUX_$fdp_release"_RHEL8= >> $new_package_list_file
sed -i "s@^OVS_SELINUX_$fdp_release"_"RHEL8=@OVS_SELINUX_$fdp_release"_"RHEL8=${OVS_SELINUX_RHEL8}@g" $new_package_list_file
echo ""
echo "Package location: $OVS_SELINUX_RHEL8"
echo ""

echo "Enter errata number for OVS 2.13 RHEL-7 for FDP $fdp_release (86957, etc.).  Hit Enter with no value if there is no errata: "
read errata
if [[ -z $errata ]]; then
	#echo "No errata provided so using most current package from prior release."
	#existing_package=$(grep -i ovs213 /home/ralongi/git/kernel/networking/openvswitch/common/package_list.sh | grep -i rhel7 | tail -n1)
	#echo $existing_package >> $new_package_list_file
	echo "No errata provided so this package will not be added for FDP $fdp_release"
	echo ""
else
	build=$(curl -s --netrc https://errata.devel.redhat.com/advisory/$errata | grep openvswitch | grep -i div | grep 'Added RPM files of build' | awk '{print $7}')
	build_id=$(echo $build | awk -F "." '{print $4}'  | awk -F "-" '{print $NF}')
	package_url="http://download.devel.redhat.com/brewroot/packages/openvswitch2.13/2.13.0/$build_id.el7fdp/x86_64/"$build".x86_64.rpm"
	http_code=$(curl --silent --head --write-out '%{http_code}' "$package_url" | grep HTTP | awk '{print $2}')
	if [[ "$http_code" -ne 200 ]]; then echo "$package_url is NOT a valid link.  Exiting..."; exit 1; fi
	sedeasy "ovs_213_rhel7_ver" "$version" "$new_package_list_temp_file"
	echo "OVS213_$fdp_release"_RHEL7= >> $new_package_list_file
	sed -i "s@^OVS213_$fdp_release"_"RHEL7=@OVS213_$fdp_release"_"RHEL7=${package_url}@g" "$new_package_list_file"
	echo ""
	echo "Package location: $package_url"
	echo ""
fi

echo "Enter errata number for OVS 2.13 RHEL-8 for FDP $fdp_release (86957, etc.): "
read errata
if [[ -z $errata ]]; then
	#echo "No errata provided so using most current package from prior release."
	#existing_package=$(grep -i ovs213 /home/ralongi/git/kernel/networking/openvswitch/common/package_list.sh | grep -i rhel8 | tail -n1)
	#echo $existing_package >> $new_package_list_file
	echo "No errata provided so this package will not be added for FDP $fdp_release"
	echo ""
else
	build=$(curl -s --netrc https://errata.devel.redhat.com/advisory/$errata | grep openvswitch | grep -i div | grep 'Added RPM files of build' | awk '{print $7}')
	build_id=$(echo $build | awk -F "." '{print $4}'  | awk -F "-" '{print $NF}')
	package_url="http://download.devel.redhat.com/brewroot/packages/openvswitch2.13/2.13.0/$build_id.el8fdp/x86_64/"$build".x86_64.rpm"
	http_code=$(curl --silent --head --write-out '%{http_code}' "$package_url" | grep HTTP | awk '{print $2}')
	if [[ "$http_code" -ne 200 ]]; then echo "$package_url is NOT a valid link.  Exiting..."; exit 1; fi
	sedeasy "ovs_213_rhel8_ver" "$version" "$new_package_list_temp_file"
	echo "OVS213_$fdp_release"_RHEL8= >> $new_package_list_file
	sed -i "s@^OVS213_$fdp_release"_"RHEL8=@OVS213_$fdp_release"_"RHEL8=${package_url}@g" "$new_package_list_file"
	echo ""
	echo "Package location: $package_url"
	echo ""
fi

echo "Enter errata number for OVS 2.15 RHEL-8 for FDP $fdp_release (86957, etc.): "
read errata
if [[ -z $errata ]]; then
	#echo "No errata provided so using most current package from prior release."
	#existing_package=$(grep -i ovs215 /home/ralongi/git/kernel/networking/openvswitch/common/package_list.sh | grep -i rhel8 | tail -n1)
	#echo $existing_package >> $new_package_list_file
	echo "No errata provided so this package will not be added for FDP $fdp_release"
	echo ""
else
	build=$(curl -s --netrc https://errata.devel.redhat.com/advisory/$errata | grep openvswitch | grep -i div | grep 'Added RPM files of build' | awk '{print $7}')
	build_id=$(echo $build | awk -F "." '{print $4}'  | awk -F "-" '{print $NF}')
	package_url="http://download.devel.redhat.com/brewroot/packages/openvswitch2.15/2.15.0/$build_id.el8fdp/x86_64/"$build".x86_64.rpm"
	http_code=$(curl --silent --head --write-out '%{http_code}' "$package_url" | grep HTTP | awk '{print $2}')
	if [[ "$http_code" -ne 200 ]]; then echo "$package_url is NOT a valid link.  Exiting..."; exit 1; fi
	sedeasy "ovs_215_rhel8_ver" "$version" "$new_package_list_temp_file"
	echo "OVS215_$fdp_release"_RHEL8= >> $new_package_list_file
	sed -i "s@^OVS215_$fdp_release"_"RHEL8=@OVS215_$fdp_release"_"RHEL8=${package_url}@g" "$new_package_list_file"
	echo ""
	echo "Package location: $package_url"
	echo ""
fi

echo "Enter errata number for OVS 2.16 RHEL-8 for FDP $fdp_release (86957, etc.): "
read errata
if [[ -z $errata ]]; then
	#echo "No errata provided so using most current package from prior release."
	#existing_package=$(grep -i ovs216 /home/ralongi/git/kernel/networking/openvswitch/common/package_list.sh | grep -i rhel8 | tail -n1)
	#echo $existing_package >> $new_package_list_file
	echo "No errata provided so this package will not be added for FDP $fdp_release"
	echo ""
else
	build=$(curl -s --netrc https://errata.devel.redhat.com/advisory/$errata | grep openvswitch | grep -i div | grep 'Added RPM files of build' | awk '{print $7}')
	build_id=$(echo $build | awk -F "." '{print $4}'  | awk -F "-" '{print $NF}')
	package_url="http://download.devel.redhat.com/brewroot/packages/openvswitch2.16/2.16.0/$build_id.el8fdp/x86_64/"$build".x86_64.rpm"
	http_code=$(curl --silent --head --write-out '%{http_code}' "$package_url" | grep HTTP | awk '{print $2}')
	if [[ "$http_code" -ne 200 ]]; then echo "$package_url is NOT a valid link.  Exiting..."; exit 1; fi
	sedeasy "ovs_216_rhel8_ver" "$version" "$new_package_list_temp_file"
	echo "OVS216_$fdp_release"_RHEL8= >> $new_package_list_file
	sed -i "s@^OVS216_$fdp_release"_"RHEL8=@OVS216_$fdp_release"_"RHEL8=${package_url}@g" "$new_package_list_file"
	echo ""
	echo "Package location: $package_url"
	echo ""
fi

echo "Enter errata number for OVN 2.13 RHEL-8 for FDP $fdp_release (86957, etc.): "
read errata
if [[ -z $errata ]]; then
	#echo "No errata provided so using most current package from prior release."
	#existing_package=$(grep -i ovn213 /home/ralongi/git/kernel/networking/openvswitch/common/package_list.sh | grep -i rhel8 | tail -n1)
	#echo $existing_package >> $new_package_list_file
	echo "No errata provided so this package will not be added for FDP $fdp_release"
	echo ""
else
	build=$(curl -s --netrc https://errata.devel.redhat.com/advisory/$errata | grep ovn | grep -i div | grep 'Added RPM files of build' | awk '{print $7}')
	directory_id=$(echo $build | awk -F "-" '{print $2}')
	build_id=$(echo $build | awk -F "." '{print $4}'  | awk -F "-" '{print $NF}')
	ovn_common_package_url="http://download.devel.redhat.com/brewroot/packages/ovn2.13/$directory_id/"$build_id".el8fdp/x86_64/$build.x86_64.rpm"
	ovn_central_package_url="http://download.devel.redhat.com/brewroot/packages/ovn2.13/$directory_id/"$build_id".el8fdp/x86_64/ovn2.13-central-$directory_id-$build_id.el8fdp.x86_64.rpm"
	ovn_host_package_url="http://download.devel.redhat.com/brewroot/packages/ovn2.13/$directory_id/"$build_id".el8fdp/x86_64/ovn2.13-host-$directory_id-$build_id.el8fdp.x86_64.rpm"
	http_code=$(curl --silent --head --write-out '%{http_code}' "$ovn_common_package_url" | grep HTTP | awk '{print $2}')
	if [[ "$http_code" -ne 200 ]]; then echo "$ovn_common_package_url is NOT a valid link.  Exiting..."; exit 1; fi
	http_code=$(curl --silent --head --write-out '%{http_code}' "$ovn_central_package_url" | grep HTTP | awk '{print $2}')
	if [[ "$http_code" -ne 200 ]]; then echo "$ovn_central_package_url is NOT a valid link.  Exiting..."; exit 1; fi
	http_code=$(curl --silent --head --write-out '%{http_code}' "$ovn_host_package_url" | grep HTTP | awk '{print $2}')
	if [[ "$http_code" -ne 200 ]]; then echo "$ovn_host_package_url is NOT a valid link.  Exiting..."; exit 1; fi
	echo "OVN_COMMON_213_$fdp_release"_RHEL8= >> $new_package_list_file
	sed -i "s@^OVN_COMMON_213_$fdp_release"_"RHEL8=@OVN_COMMON_213_$fdp_release"_"RHEL8=${ovn_common_package_url}@g" $new_package_list_file
	echo "OVN_CENTRAL_213_$fdp_release"_RHEL8= >> $new_package_list_file
	sed -i "s@^OVN_CENTRAL_213_$fdp_release"_"RHEL8=@OVN_CENTRAL_213_$fdp_release"_"RHEL8=${ovn_central_package_url}@g" $new_package_list_file
	echo "OVN_HOST_213_$fdp_release"_RHEL8= >> $new_package_list_file
	sed -i "s@^OVN_HOST_213_$fdp_release"_"RHEL8=@OVN_HOST_213_$fdp_release"_"RHEL8=${ovn_host_package_url}@g" $new_package_list_file
	echo ""
	echo "Package location: $ovn_common_package_url"
	echo "Package location: $ovn_central_package_url"
	echo "Package location: $ovn_host_package_url"
	echo ""
fi

echo "Enter errata number for OVN 'Year' RHEL-8 for FDP $fdp_release (86957, etc.): "
read errata
if [[ -z $errata ]]; then
	#echo "No errata provided so using most current package from prior release."
	#existing_package=$(grep -i ovn213 /home/ralongi/git/kernel/networking/openvswitch/common/package_list.sh | grep -i rhel8 | tail -n1)
	#echo $existing_package >> $new_package_list_file
	echo "No errata provided so this package will not be added for FDP $fdp_release"
	echo ""
else
	build=$(curl -s --netrc https://errata.devel.redhat.com/advisory/$errata | grep ovn | grep -i div | grep 'Added RPM files of build' | awk '{print $7}')
	year=$(echo $build | awk -F "-" '{print $2}')
	directory_id=$(echo $build | awk -F "-" '{print $3}')
	build_id=$(echo $build | awk -F "." '{print $3}'  | awk -F "-" '{print $NF}')
	ovn_common_package_url="http://download.devel.redhat.com/brewroot/packages/ovn-$year/$directory_id/"$build_id".el8fdp/x86_64/$build.x86_64.rpm"
	ovn_central_package_url="http://download.devel.redhat.com/brewroot/packages/ovn-$year/$directory_id/"$build_id".el8fdp/x86_64/ovn-$year-central-$directory_id-$build_id.el8fdp.x86_64.rpm"
	ovn_host_package_url="http://download.devel.redhat.com/brewroot/packages/ovn-$year/$directory_id/"$build_id".el8fdp/x86_64/ovn-$year-host-$directory_id-$build_id.el8fdp.x86_64.rpm"
	http_code=$(curl --silent --head --write-out '%{http_code}' "$ovn_common_package_url" | grep HTTP | awk '{print $2}')
	if [[ "$http_code" -ne 200 ]]; then echo "$ovn_common_package_url is NOT a valid link.  Exiting..."; exit 1; fi
	http_code=$(curl --silent --head --write-out '%{http_code}' "$ovn_central_package_url" | grep HTTP | awk '{print $2}')
	if [[ "$http_code" -ne 200 ]]; then echo "$ovn_central_package_url is NOT a valid link.  Exiting..."; exit 1; fi
	http_code=$(curl --silent --head --write-out '%{http_code}' "$ovn_host_package_url" | grep HTTP | awk '{print $2}')
	if [[ "$http_code" -ne 200 ]]; then echo "$ovn_host_package_url is NOT a valid link.  Exiting..."; exit 1; fi
	echo "OVN_COMMON_"$year"_$fdp_release"_RHEL8= >> $new_package_list_file
	sed -i "s@^OVN_COMMON_"$year"_$fdp_release"_"RHEL8=@OVN_COMMON_"$year"_$fdp_release"_"RHEL8=${ovn_common_package_url}@g" $new_package_list_file
	echo "OVN_CENTRAL_"$year"_$fdp_release"_RHEL8= >> $new_package_list_file
	sed -i "s@^OVN_CENTRAL_"$year"_$fdp_release"_"RHEL8=@OVN_CENTRAL_"$year"_$fdp_release"_"RHEL8=${ovn_central_package_url}@g" $new_package_list_file
	echo "OVN_HOST_$year_$fdp_release"_RHEL8= >> $new_package_list_file
	sed -i "s@^OVN_HOST_$year_$fdp_release"_"RHEL8=@OVN_HOST_"$year"_$fdp_release"_"RHEL8=${ovn_host_package_url}@g" $new_package_list_file
	echo ""
	echo "Package location: $ovn_common_package_url"
	echo "Package location: $ovn_central_package_url"
	echo "Package location: $ovn_host_package_url"
	echo ""
fi

cat $new_package_list_file >> /home/ralongi/git/kernel/networking/openvswitch/common/package_list.sh

if [[ $checkin_git == "yes" ]]; then
	pushd /home/ralongi/git/kernel/networking/
	git add openvswitch/common/package_list.sh
	git commit -o openvswitch/common/package_list.sh -m "Added FDP $fdp_relase packages."
	git pull --rebase && git push
	/home/ralongi/github/tools/scripts/bkrtag.sh openvswitch/common/
	popd
else
	echo "Skipping check-in of code to git..."
fi


