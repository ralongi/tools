#! /bin/bash

dbg_flag=${dbg_flag:-"set +x"}
$dbg_flag
checkin_git=${checkin_git:-"no"}
fdp_release=$1
if [[ $# -lt 1 ]]; then echo "Please provide FDP release (21H, etc):"; read fdp_release; fi
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

echo "Enter OVS SELinux RHEL-7 Version for FDP $fdp_release: "
read version
sedeasy "ovs_selinux_rhel7_ver" "$version" "$new_package_list_temp_file"
source "$new_package_list_temp_file"
http_code=$(curl --silent --head --write-out '%{http_code}' "$OVS_SELINUX_RHEL7" | grep HTTP | awk '{print $2}')
if [[ "$http_code" -ne 200 ]]; then echo "$OVS_SELINUX_RHEL7 is NOT a valid link.  Exiting..."; exit 1; fi
echo "OVS_SELINUX_$fdp_release"_RHEL7= >> $new_package_list_file
sed -i "s@^OVS_SELINUX_$fdp_release"_"RHEL7=@OVS_SELINUX_$fdp_release"_"RHEL7=${OVS_SELINUX_RHEL7}@g" $new_package_list_file
echo ""
echo "Package location: $OVS_SELINUX__RHEL7"
echo ""

echo "Enter OVS SELinux RHEL-8 Version for FDP $fdp_release: "
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

echo "Enter OVS 2.13 RHEL-8 Version for FDP $fdp_release: "
read version
sedeasy "ovs_213_rhel8_ver" "$version" "$new_package_list_temp_file"
source "$new_package_list_temp_file"
http_code=$(curl --silent --head --write-out '%{http_code}' "$OVS213_RHEL8" | grep HTTP | awk '{print $2}')
if [[ "$http_code" -ne 200 ]]; then echo "$OVS213_RHEL8 is NOT a valid link.  Exiting..."; exit 1; fi
echo "OVS213_$fdp_release"_RHEL8= >> $new_package_list_file
#sed -i "s@^OVS213_$fdp_release"_"RHEL8=@OVS213_$fdp_release"_"RHEL8=${$OVS213_RHEL8}@g" $new_package_list_file
sed -i "s@^OVS213_$fdp_release"_"RHEL8=@OVS213_$fdp_release"_"RHEL8=${OVS213_RHEL8}@g" "$new_package_list_file"
echo ""
echo "Package location: $OVS213_RHEL8"
echo ""

echo "Enter OVS 2.15 RHEL-8 Version for FDP $fdp_release: "
read version
sedeasy "ovs_215_rhel8_ver" "$version" "$new_package_list_temp_file"
source "$new_package_list_temp_file"
http_code=$(curl --silent --head --write-out '%{http_code}' "$OVS215_RHEL8" | grep HTTP | awk '{print $2}')
if [[ "$http_code" -ne 200 ]]; then echo "$OVS215_RHEL8 is NOT a valid link.  Exiting..."; exit 1; fi
echo "OVS215_$fdp_release"_RHEL8= >> $new_package_list_file
sed -i "s@^OVS215_$fdp_release"_"RHEL8=@OVS215_$fdp_release"_"RHEL8=${OVS215_RHEL8}@g" $new_package_list_file
echo ""
echo "Package location: $OVS215_RHEL8"
echo ""

echo "Enter OVS 2.16 RHEL-8 Version for FDP $fdp_release: "
read version
sedeasy "ovs_216_rhel8_ver" "$version" "$new_package_list_temp_file"
source "$new_package_list_temp_file"
http_code=$(curl --silent --head --write-out '%{http_code}' "$OVS216_RHEL8" | grep HTTP | awk '{print $2}')
if [[ "$http_code" -ne 200 ]]; then echo "$OVS216_RHEL8 is NOT a valid link.  Exiting..."; exit 1; fi
echo "OVS216_$fdp_release"_RHEL8= >> $new_package_list_file
sed -i "s@^OVS216_$fdp_release"_"RHEL8=@OVS216_$fdp_release"_"RHEL8=${OVS216_RHEL8}@g" $new_package_list_file
echo ""
echo "Package location: $OVS216_RHEL8"
echo ""

echo "Enter OVN 2.13 RHEL-8 Version for FDP $fdp_release: "
read version
sedeasy "ovn_213_rhel8_ver" "$version" "$new_package_list_temp_file"
source "$new_package_list_temp_file"
http_code=$(curl --silent --head --write-out '%{http_code}' "$OVN_COMMON_213_RHEL8" | grep HTTP | awk '{print $2}')
if [[ "$http_code" -ne 200 ]]; then echo "$OVN_COMMON_213_RHEL8 is NOT a valid link.  Exiting..."; exit 1; fi

http_code=$(curl --silent --head --write-out '%{http_code}' "$OVN_CENTRAL_213_RHEL8" | grep HTTP | awk '{print $2}')
if [[ "$http_code" -ne 200 ]]; then echo "$OVN_CENTRAL_213_RHEL8 is NOT a valid link.  Exiting..."; exit 1; fi

http_code=$(curl --silent --head --write-out '%{http_code}' "$OVN_HOST_213_RHEL8" | grep HTTP | awk '{print $2}')
if [[ "$http_code" -ne 200 ]]; then echo "$OVN_HOST_213_RHEL8 is NOT a valid link.  Exiting..."; exit 1; fi
echo "OVN_COMMON_213_$fdp_release"_RHEL8= >> $new_package_list_file
sed -i "s@^OVN_COMMON_213_$fdp_release"_"RHEL8=@OVN_COMMON_213_$fdp_release"_"RHEL8=${OVN_COMMON_213_RHEL8}@g" $new_package_list_file
echo "OVN_CENTRAL_213_$fdp_release"_RHEL8= >> $new_package_list_file
sed -i "s@^OVN_CENTRAL_213_$fdp_release"_"RHEL8=@OVN_CENTRAL_213_$fdp_release"_"RHEL8=${OVN_CENTRAL_213_RHEL8}@g" $new_package_list_file
echo "OVN_HOST_213_$fdp_release"_RHEL8= >> $new_package_list_file
sed -i "s@^OVN_HOST_213_$fdp_release"_"RHEL8=@OVN_HOST_213_$fdp_release"_"RHEL8=${OVN_HOST_213_RHEL8}@g" $new_package_list_file
echo ""
echo "Package location: $OVN_COMMON_213_RHEL8"
echo "Package location: $OVN_CENTRAL_213_RHEL8"
echo "Package location: $OVN_HOST_213_RHEL8"
echo ""

echo "Enter OVN 2021 RHEL-8 Version: "
read version
sedeasy "ovn_2021_rhel8_ver" "$version" "$new_package_list_temp_file"
source "$new_package_list_temp_file"
http_code=$(curl --silent --head --write-out '%{http_code}' "$OVN_COMMON_2021_RHEL8" | grep HTTP | awk '{print $2}')
if [[ "$http_code" -ne 200 ]]; then echo "$OVN_COMMON_2021_RHEL8 is NOT a valid link.  Exiting..."; exit 1; fi

http_code=$(curl --silent --head --write-out '%{http_code}' "$OVN_CENTRAL_2021_RHEL8" | grep HTTP | awk '{print $2}')
if [[ "$http_code" -ne 200 ]]; then echo "$OVN_CENTRAL_2021_RHEL8 is NOT a valid link.  Exiting..."; exit 1; fi

http_code=$(curl --silent --head --write-out '%{http_code}' "$OVN_HOST_2021_RHEL8" | grep HTTP | awk '{print $2}')
if [[ "$http_code" -ne 200 ]]; then echo "$OVN_HOST_2021_RHEL8 is NOT a valid link.  Exiting..."; exit 1; fi
echo "OVN_COMMON_2021_$fdp_release"_RHEL8= >> $new_package_list_file
sed -i "s@^OVN_COMMON_2021_$fdp_release"_"RHEL8=@OVN_COMMON_2021_$fdp_release"_"RHEL8=${OVN_COMMON_2021_RHEL8}@g" $new_package_list_file
echo "OVN_CENTRAL_2021_$fdp_release"_RHEL8= >> $new_package_list_file
sed -i "s@^OVN_CENTRAL_2021_$fdp_release"_"RHEL8=@OVN_CENTRAL_2021_$fdp_release"_"RHEL8=${OVN_CENTRAL_2021_RHEL8}@g" $new_package_list_file
echo "OVN_HOST_2021_$fdp_release"_RHEL8= >> $new_package_list_file
sed -i "s@^OVN_HOST_2021_$fdp_release"_"RHEL8=@OVN_HOST_2021_$fdp_release"_"RHEL8=${OVN_HOST_2021_RHEL8}@g" $new_package_list_file
echo ""
echo "Package location: $OVN_COMMON_2021_RHEL8"
echo "Package location: $OVN_CENTRAL_2021_RHEL8"
echo "Package location: $OVN_HOST_2021_RHEL8"
echo ""

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

