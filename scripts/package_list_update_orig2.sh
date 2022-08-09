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
echo "" >> $new_package_list_file
echo "# FDP $fdp_release Packages" >> $new_package_list_file

selinux_version=$(curl -sL http://download-node-02.eng.bos.redhat.com/brewroot/packages/openvswitch-selinux-extra-policy/1.0/ | grep el7 | tail -n1 | awk -F ">" '{print $3}' | awk -F "/" '{print $1}' | awk -F "." '{print $1}')
package_url=http://download-node-02.eng.bos.redhat.com/brewroot/packages/openvswitch-selinux-extra-policy/1.0/$selinux_version.el7fdp/noarch/openvswitch-selinux-extra-policy-1.0-$selinux_version.el7fdp.noarch.rpm
http_code=$(curl --silent --head --write-out '%{http_code}' "$package_url" | grep HTTP | awk '{print $2}')
if [[ "$http_code" -ne 200 ]]; then echo "$package_url is NOT a valid link.  Exiting..."; exit 1; fi
echo "OVS_SELINUX_$fdp_release"_RHEL7=${package_url} >> $new_package_list_file
echo ""
echo "Package location: $package_url"
echo ""

selinux_version=$(curl -sL http://download-node-02.eng.bos.redhat.com/brewroot/packages/openvswitch-selinux-extra-policy/1.0/ | grep el8 | tail -n1 | awk -F ">" '{print $3}' | awk -F "/" '{print $1}' | awk -F "." '{print $1}')
package_url=http://download-node-02.eng.bos.redhat.com/brewroot/packages/openvswitch-selinux-extra-policy/1.0/$selinux_version.el8fdp/noarch/openvswitch-selinux-extra-policy-1.0-$selinux_version.el8fdp.noarch.rpm
http_code=$(curl --silent --head --write-out '%{http_code}' "$package_url" | grep HTTP | awk '{print $2}')
if [[ "$http_code" -ne 200 ]]; then echo "$package_url is NOT a valid link.  Exiting..."; exit 1; fi
echo "OVS_SELINUX_$fdp_release"_RHEL8=${package_url} >> $new_package_list_file
echo ""
echo "Package location: $package_url"
echo ""

selinux_version=$(curl -sL http://download-node-02.eng.bos.redhat.com/brewroot/packages/openvswitch-selinux-extra-policy/1.0/ | grep el9 | tail -n1 | awk -F ">" '{print $3}' | awk -F "/" '{print $1}' | awk -F "." '{print $1}')
package_url=http://download-node-02.eng.bos.redhat.com/brewroot/packages/openvswitch-selinux-extra-policy/1.0/$selinux_version.el9fdp/noarch/openvswitch-selinux-extra-policy-1.0-$selinux_version.el9fdp.noarch.rpm
http_code=$(curl --silent --head --write-out '%{http_code}' "$package_url" | grep HTTP | awk '{print $2}')
if [[ "$http_code" -ne 200 ]]; then echo "$package_url is NOT a valid link.  Exiting..."; exit 1; fi
echo "OVS_SELINUX_$fdp_release"_RHEL9=${package_url} >> $new_package_list_file
echo ""
echo "Package location: $package_url"
echo ""

echo "Enter errata number for OVS 2.13 RHEL-7 for FDP $fdp_release (86957, etc.).  Hit Enter with no value if there is no errata: "
read errata
if [[ -z $errata ]]; then
	echo "No errata provided so this package will not be added for FDP $fdp_release"
	echo ""
else
	curl -su : --negotiate https://errata.devel.redhat.com/api/v1/erratum/$errata/builds | jq > ~/temp/builds.txt
	build=$(grep -A2 '"x86_64": \[' ~/temp/builds.txt | tail -n1 | awk -F '"' '{print $2}')	
	build_id=$(echo $build | awk -F "." '{print $4}'  | awk -F "-" '{print $NF}')
	package_url="http://download-node-02.eng.bos.redhat.com/brewroot/packages/openvswitch2.13/2.13.0/$build_id.el7fdp/x86_64/$build"
	http_code=$(curl --silent --head --write-out '%{http_code}' "$package_url" | grep HTTP | awk '{print $2}')
	if [[ "$http_code" -ne 200 ]]; then echo "$package_url is NOT a valid link.  Exiting..."; exit 1; fi
	echo "OVS213_$fdp_release"_RHEL7=${package_url} >> $new_package_list_file
	echo ""
	echo "Package location: $package_url"
	echo ""
fi

echo "Enter errata number for OVS 2.13 RHEL-8 for FDP $fdp_release (86957, etc.): "
read errata
if [[ -z $errata ]]; then
	echo "No errata provided so this package will not be added for FDP $fdp_release"
	echo ""
else
	curl -su : --negotiate https://errata.devel.redhat.com/api/v1/erratum/$errata/builds | jq > ~/temp/builds.txt
	build=$(grep -A2 '"x86_64": \[' ~/temp/builds.txt | tail -n1 | awk -F '"' '{print $2}')	
	build_id=$(echo $build | awk -F "." '{print $4}'  | awk -F "-" '{print $NF}')
	package_url="http://download-node-02.eng.bos.redhat.com/brewroot/packages/openvswitch2.13/2.13.0/$build_id.el8fdp/x86_64/$build"
	http_code=$(curl --silent --head --write-out '%{http_code}' "$package_url" | grep HTTP | awk '{print $2}')
	if [[ "$http_code" -ne 200 ]]; then echo "$package_url is NOT a valid link.  Exiting..."; exit 1; fi
	echo "OVS213_$fdp_release"_RHEL8=${package_url} >> $new_package_list_file
	echo ""
	echo "Package location: $package_url"
	echo ""
fi

echo "Enter errata number for OVS 2.15 RHEL-8 for FDP $fdp_release (86957, etc.): "
read errata
if [[ -z $errata ]]; then
	echo "No errata provided so this package will not be added for FDP $fdp_release"
	echo ""
else
	curl -su : --negotiate https://errata.devel.redhat.com/api/v1/erratum/$errata/builds | jq > ~/temp/builds.txt
	build=$(grep -A2 '"x86_64": \[' ~/temp/builds.txt | tail -n1 | awk -F '"' '{print $2}')
	build_id=$(echo $build | awk -F "." '{print $4}'  | awk -F "-" '{print $NF}')
	package_url="http://download-node-02.eng.bos.redhat.com/brewroot/packages/openvswitch2.15/2.15.0/$build_id.el8fdp/x86_64/$build"
	http_code=$(curl --silent --head --write-out '%{http_code}' "$package_url" | grep HTTP | awk '{print $2}')
	if [[ "$http_code" -ne 200 ]]; then echo "$package_url is NOT a valid link.  Exiting..."; exit 1; fi
	echo "OVS215_$fdp_release"_RHEL8=${package_url} >> $new_package_list_file
	echo ""
	echo "Package location: $package_url"
	echo ""
fi

echo "Enter errata number for OVS 2.16 RHEL-8 for FDP $fdp_release (86957, etc.): "
read errata
if [[ -z $errata ]]; then
	echo "No errata provided so this package will not be added for FDP $fdp_release"
	echo ""
else
	curl -su : --negotiate https://errata.devel.redhat.com/api/v1/erratum/$errata/builds | jq > ~/temp/builds.txt
	build=$(grep -A2 '"x86_64": \[' ~/temp/builds.txt | tail -n1 | awk -F '"' '{print $2}')
	build_id=$(echo $build | awk -F "." '{print $4}'  | awk -F "-" '{print $NF}')
	package_url="http://download-node-02.eng.bos.redhat.com/brewroot/packages/openvswitch2.16/2.16.0/$build_id.el8fdp/x86_64/$build"
	http_code=$(curl --silent --head --write-out '%{http_code}' "$package_url" | grep HTTP | awk '{print $2}')
	if [[ "$http_code" -ne 200 ]]; then echo "$package_url is NOT a valid link.  Exiting..."; exit 1; fi
	echo "OVS216_$fdp_release"_RHEL8=${package_url} >> $new_package_list_file
	echo ""
	echo "Package location: $package_url"
	echo ""
fi

echo "Enter errata number for OVS 2.17 RHEL-8 for FDP $fdp_release (86957, etc.): "
read errata
if [[ -z $errata ]]; then
	echo "No errata provided so this package will not be added for FDP $fdp_release"
	echo ""
else
	curl -su : --negotiate https://errata.devel.redhat.com/api/v1/erratum/$errata/builds | jq > ~/temp/builds.txt
	build=$(grep -A2 '"x86_64": \[' ~/temp/builds.txt | tail -n1 | awk -F '"' '{print $2}')
	build_id=$(echo $build | awk -F "." '{print $4}'  | awk -F "-" '{print $NF}')
	package_url="http://download-node-02.eng.bos.redhat.com/brewroot/packages/openvswitch2.17/2.17.0/$build_id.el8fdp/x86_64/$build"
	http_code=$(curl --silent --head --write-out '%{http_code}' "$package_url" | grep HTTP | awk '{print $2}')
	if [[ "$http_code" -ne 200 ]]; then echo "$package_url is NOT a valid link.  Exiting..."; exit 1; fi
	echo "OVS216_$fdp_release"_RHEL8=${package_url} >> $new_package_list_file
	echo ""
	echo "Package location: $package_url"
	echo ""
fi

echo "Enter errata number for OVS 2.15 RHEL-9 for FDP $fdp_release (86957, etc.): "
read errata
if [[ -z $errata ]]; then
	echo "No errata provided so this package will not be added for FDP $fdp_release"
	echo ""
else
	curl -su : --negotiate https://errata.devel.redhat.com/api/v1/erratum/$errata/builds | jq > ~/temp/builds.txt
	build=$(grep -A2 '"x86_64": \[' ~/temp/builds.txt | tail -n1 | awk -F '"' '{print $2}')
	build_id=$(echo $build | awk -F "." '{print $4}'  | awk -F "-" '{print $NF}')
	package_url="http://download-node-02.eng.bos.redhat.com/brewroot/packages/openvswitch2.15/2.15.0/$build_id.el9fdp/x86_64/$build"
	http_code=$(curl --silent --head --write-out '%{http_code}' "$package_url" | grep HTTP | awk '{print $2}')
	if [[ "$http_code" -ne 200 ]]; then echo "$package_url is NOT a valid link.  Exiting..."; exit 1; fi
	echo "OVS215_$fdp_release"_RHEL9=${package_url} >> $new_package_list_file
	echo ""
	echo "Package location: $package_url"
	echo ""
fi

echo "Enter errata number for OVS 2.17 RHEL-9 for FDP $fdp_release (86957, etc.): "
read errata
if [[ -z $errata ]]; then
	echo "No errata provided so this package will not be added for FDP $fdp_release"
	echo ""
else
	curl -su : --negotiate https://errata.devel.redhat.com/api/v1/erratum/$errata/builds | jq > ~/temp/builds.txt
	build=$(grep -A2 '"x86_64": \[' ~/temp/builds.txt | tail -n1 | awk -F '"' '{print $2}')
	build_id=$(echo $build | awk -F "." '{print $4}'  | awk -F "-" '{print $NF}')
	package_url="http://download-node-02.eng.bos.redhat.com/brewroot/packages/openvswitch2.17/2.17.0/$build_id.el9fdp/x86_64/$build"
	http_code=$(curl --silent --head --write-out '%{http_code}' "$package_url" | grep HTTP | awk '{print $2}')
	if [[ "$http_code" -ne 200 ]]; then echo "$package_url is NOT a valid link.  Exiting..."; exit 1; fi
	echo "OVS217_$fdp_release"_RHEL9=${package_url} >> $new_package_list_file
	echo ""
	echo "Package location: $package_url"
	echo ""
fi

echo "Enter errata number for OVN 2.13 RHEL-8 for FDP $fdp_release (86957, etc.): "
read errata
if [[ -z $errata ]]; then
	echo "No errata provided so this package will not be added for FDP $fdp_release"
	echo ""
else
	curl -su : --negotiate https://errata.devel.redhat.com/api/v1/erratum/$errata/builds | jq > ~/temp/builds.txt
	ovn_common_build=$(grep -A1 '"x86_64": \[' ~/temp/builds.txt | tail -n1 | awk -F '"' '{print $2}')
	ovn_central_build=$(grep -A2 '"x86_64": \[' ~/temp/builds.txt | tail -n1 | awk -F '"' '{print $2}')
	ovn_host_build=$(grep -A3 '"x86_64": \[' ~/temp/builds.txt | tail -n1 | awk -F '"' '{print $2}')
	directory_id=$(echo $ovn_common_build | awk -F "-" '{print $2}')
	build_id=$(echo $ovn_common_build | awk -F "." '{print $4}'  | awk -F "-" '{print $NF}')
	ovn_common_package_url="http://download-node-02.eng.bos.redhat.com/brewroot/packages/ovn2.13/$directory_id/"$build_id".el8fdp/x86_64/$ovn_common_build"
	ovn_central_package_url="http://download-node-02.eng.bos.redhat.com/brewroot/packages/ovn2.13/$directory_id/"$build_id".el8fdp/x86_64/$ovn_central_build"
	ovn_host_package_url="http://download-node-02.eng.bos.redhat.com/brewroot/packages/ovn2.13/$directory_id/"$build_id".el8fdp/x86_64/$ovn_host_build"
	http_code=$(curl --silent --head --write-out '%{http_code}' "$ovn_common_package_url" | grep HTTP | awk '{print $2}')
	if [[ "$http_code" -ne 200 ]]; then echo "$ovn_common_package_url is NOT a valid link.  Exiting..."; exit 1; fi
	http_code=$(curl --silent --head --write-out '%{http_code}' "$ovn_central_package_url" | grep HTTP | awk '{print $2}')
	if [[ "$http_code" -ne 200 ]]; then echo "$ovn_central_package_url is NOT a valid link.  Exiting..."; exit 1; fi
	http_code=$(curl --silent --head --write-out '%{http_code}' "$ovn_host_package_url" | grep HTTP | awk '{print $2}')
	if [[ "$http_code" -ne 200 ]]; then echo "$ovn_host_package_url is NOT a valid link.  Exiting..."; exit 1; fi
	echo "OVN_COMMON_213_"$fdp_release"_RHEL8=${ovn_common_package_url}" >> $new_package_list_file
	echo "OVN_CENTRAL_213_"$fdp_release"_RHEL8=${ovn_central_package_url}" >> $new_package_list_file
	echo "OVN_HOST_213_"$fdp_release"_RHEL8=${ovn_host_package_url}" >> $new_package_list_file
	echo ""
	echo "Package location: $ovn_common_package_url"
	echo "Package location: $ovn_central_package_url"
	echo "Package location: $ovn_host_package_url"
	echo ""
fi

echo "Enter errata number for OVN-XXXX RHEL-8 for FDP $fdp_release (86957, etc.): "
read errata
if [[ -z $errata ]]; then
	echo "No errata provided so this package will not be added for FDP $fdp_release"
	echo ""
else
	curl -su : --negotiate https://errata.devel.redhat.com/api/v1/erratum/$errata/builds | jq > ~/temp/builds.txt
	ovn_common_build=$(grep -A1 '"x86_64": \[' ~/temp/builds.txt | tail -n1 | awk -F '"' '{print $2}')
	ovn_central_build=$(grep -A2 '"x86_64": \[' ~/temp/builds.txt | tail -n1 | awk -F '"' '{print $2}')
	ovn_host_build=$(grep -A3 '"x86_64": \[' ~/temp/builds.txt | tail -n1 | awk -F '"' '{print $2}')
	year=$(echo $ovn_common_build | awk -F "-" '{print $2}')
	directory_id=$(echo $ovn_common_build | awk -F "-" '{print $3}')
	build_id=$(echo $ovn_common_build | awk -F "." '{print $3}'  | awk -F "-" '{print $NF}')
	ovn_common_package_url="http://download-node-02.eng.bos.redhat.com/brewroot/packages/ovn-$year/$directory_id/"$build_id".el8fdp/x86_64/$ovn_common_build"
	ovn_central_package_url="http://download-node-02.eng.bos.redhat.com/brewroot/packages/ovn-$year/$directory_id/"$build_id".el8fdp/x86_64/$ovn_central_build"
	ovn_host_package_url="http://download-node-02.eng.bos.redhat.com/brewroot/packages/ovn-$year/$directory_id/"$build_id".el8fdp/x86_64/$ovn_host_build"
	http_code=$(curl --silent --head --write-out '%{http_code}' "$ovn_common_package_url" | grep HTTP | awk '{print $2}')
	if [[ "$http_code" -ne 200 ]]; then echo "$ovn_common_package_url is NOT a valid link.  Exiting..."; exit 1; fi
	http_code=$(curl --silent --head --write-out '%{http_code}' "$ovn_central_package_url" | grep HTTP | awk '{print $2}')
	if [[ "$http_code" -ne 200 ]]; then echo "$ovn_central_package_url is NOT a valid link.  Exiting..."; exit 1; fi
	http_code=$(curl --silent --head --write-out '%{http_code}' "$ovn_host_package_url" | grep HTTP | awk '{print $2}')
	if [[ "$http_code" -ne 200 ]]; then echo "$ovn_host_package_url is NOT a valid link.  Exiting..."; exit 1; fi
	echo "OVN_COMMON_"$revised_year"_$fdp_release"_RHEL8=${ovn_common_package_url} >> $new_package_list_file
	echo "OVN_CENTRAL_"$revised_year"_$fdp_release"_RHEL8=${ovn_central_package_url} >> $new_package_list_file
	echo "OVN_HOST_"$revised_year"_$fdp_release"_RHEL8=${ovn_host_package_url} >> $new_package_list_file
	echo ""
	echo "Package location: $ovn_common_package_url"
	echo "Package location: $ovn_central_package_url"
	echo "Package location: $ovn_host_package_url"
	echo ""
fi

echo "Enter errata number for OVN-XX.XX RHEL-8 for FDP $fdp_release (86957, etc.): "
read errata
if [[ -z $errata ]]; then
	echo "No errata provided so this package will not be added for FDP $fdp_release"
	echo ""
else
	curl -su : --negotiate https://errata.devel.redhat.com/api/v1/erratum/$errata/builds | jq > ~/temp/builds.txt
	ovn_common_build=$(grep -A1 '"x86_64": \[' ~/temp/builds.txt | tail -n1 | awk -F '"' '{print $2}')
	ovn_central_build=$(grep -A2 '"x86_64": \[' ~/temp/builds.txt | tail -n1 | awk -F '"' '{print $2}')
	ovn_host_build=$(grep -A3 '"x86_64": \[' ~/temp/builds.txt | tail -n1 | awk -F '"' '{print $2}')
	year=$(echo $ovn_common_build | awk -F "-" '{print $1}' | tr -d 'ovn')
	revised_year=$(echo $year | tr -d ".")
	point1=$(echo $ovn_common_build  | awk -F "." '{print $4}' | awk -F "-" '{print $1}')
	point2=$(echo $ovn_common_build  | awk -F "." '{print $4}' | awk -F "-" '{print $2}')
	
	ovn_common_package_url="http://download-node-02.eng.bos.redhat.com/brewroot/packages/ovn$year/$year.$point1/$point2.el8fdp/x86_64/$ovn_common_build"
	ovn_central_package_url="http://download-node-02.eng.bos.redhat.com/brewroot/packages/ovn$year/$year.$point1/$point2.el8fdp/x86_64/$ovn_central_build"
	ovn_host_package_url="http://download-node-02.eng.bos.redhat.com/brewroot/packages/ovn$year/$year.$point1/$point2.el8fdp/x86_64/$ovn_host_build"
	http_code=$(curl --silent --head --write-out '%{http_code}' "$ovn_common_package_url" | grep HTTP | awk '{print $2}')
	if [[ "$http_code" -ne 200 ]]; then echo "$ovn_common_package_url is NOT a valid link.  Exiting..."; exit 1; fi
	http_code=$(curl --silent --head --write-out '%{http_code}' "$ovn_central_package_url" | grep HTTP | awk '{print $2}')
	if [[ "$http_code" -ne 200 ]]; then echo "$ovn_central_package_url is NOT a valid link.  Exiting..."; exit 1; fi
	http_code=$(curl --silent --head --write-out '%{http_code}' "$ovn_host_package_url" | grep HTTP | awk '{print $2}')
	if [[ "$http_code" -ne 200 ]]; then echo "$ovn_host_package_url is NOT a valid link.  Exiting..."; exit 1; fi
	echo "OVN_COMMON_"$revised_year"_$fdp_release"_RHEL8=${ovn_common_package_url} >> $new_package_list_file
	echo "OVN_CENTRAL_"$revised_year"_$fdp_release"_RHEL8=${ovn_central_package_url} >> $new_package_list_file
	echo "OVN_HOST_"$revised_year"_$fdp_release"_RHEL8=${ovn_host_package_url} >> $new_package_list_file
	echo ""
	echo "Package location: $ovn_common_package_url"
	echo "Package location: $ovn_central_package_url"
	echo "Package location: $ovn_host_package_url"
	echo ""
fi

echo "Enter errata number for OVN-XX.XX RHEL-9 for FDP $fdp_release (86957, etc.): "
read errata
if [[ -z $errata ]]; then
	echo "No errata provided so this package will not be added for FDP $fdp_release"
	echo ""
else
	curl -su : --negotiate https://errata.devel.redhat.com/api/v1/erratum/$errata/builds | jq > ~/temp/builds.txt
	ovn_common_build=$(grep -A1 '"x86_64": \[' ~/temp/builds.txt | tail -n1 | awk -F '"' '{print $2}')
	ovn_central_build=$(grep -A2 '"x86_64": \[' ~/temp/builds.txt | tail -n1 | awk -F '"' '{print $2}')
	ovn_host_build=$(grep -A3 '"x86_64": \[' ~/temp/builds.txt | tail -n1 | awk -F '"' '{print $2}')
	year=$(echo $ovn_common_build | awk -F "-" '{print $1}' | tr -d 'ovn')
	revised_year=$(echo $year | tr -d ".")
	point1=$(echo $ovn_common_build  | awk -F "." '{print $4}' | awk -F "-" '{print $1}')
	point2=$(echo $ovn_common_build  | awk -F "." '{print $4}' | awk -F "-" '{print $2}')
	
	ovn_common_package_url="http://download-node-02.eng.bos.redhat.com/brewroot/packages/ovn$year/$year.$point1/$point2.el9fdp/x86_64/$ovn_common_build"
	ovn_central_package_url="http://download-node-02.eng.bos.redhat.com/brewroot/packages/ovn$year/$year.$point1/$point2.el9fdp/x86_64/$ovn_central_build"
	ovn_host_package_url="http://download-node-02.eng.bos.redhat.com/brewroot/packages/ovn$year/$year.$point1/$point2.el9fdp/x86_64/$ovn_host_build"
	http_code=$(curl --silent --head --write-out '%{http_code}' "$ovn_common_package_url" | grep HTTP | awk '{print $2}')
	if [[ "$http_code" -ne 200 ]]; then echo "$ovn_common_package_url is NOT a valid link.  Exiting..."; exit 1; fi
	http_code=$(curl --silent --head --write-out '%{http_code}' "$ovn_central_package_url" | grep HTTP | awk '{print $2}')
	if [[ "$http_code" -ne 200 ]]; then echo "$ovn_central_package_url is NOT a valid link.  Exiting..."; exit 1; fi
	http_code=$(curl --silent --head --write-out '%{http_code}' "$ovn_host_package_url" | grep HTTP | awk '{print $2}')
	if [[ "$http_code" -ne 200 ]]; then echo "$ovn_host_package_url is NOT a valid link.  Exiting..."; exit 1; fi
	echo "OVN_COMMON_"$revised_year"_$fdp_release"_RHEL9=${ovn_common_package_url} >> $new_package_list_file
	echo "OVN_CENTRAL_"$revised_year"_$fdp_release"_RHEL9=${ovn_central_package_url} >> $new_package_list_file
	echo "OVN_HOST_"$revised_year"_$fdp_release"_RHEL9=${ovn_host_package_url} >> $new_package_list_file
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


