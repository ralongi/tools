#!/bin/bash

sudo yum localinstall -y http://download.lab.bos.redhat.com/rcm-guest/puddles/OpenStack/rhos-release/rhos-release-latest.noarch.rpm

check_latest_openvswitch_package()
{
	ovs_rpm_version=$1
	lp_version=$2
	ovs_arch=${ovs_arch:-"x86_64"}
	ovs_channel=${ovs_channel:-"fdp"}
	ovs_rpm_parent_location="download-node-02.eng.bos.redhat.com/brewroot/packages/openvswitch/$ovs_rpm_version"
	sudo rhos-release -x $lp_version
	sudo yum clean expire-cache
	pushd ~
	rm -Rf $ovs_rpm_version
	wget -q --execute="robots = off" --convert-links --no-parent --wait=1 "http://"$ovs_rpm_parent_location
	partial_latest_ovs_ver=$(grep $ovs_channel $ovs_rpm_version | tail -n1 | awk -F "$ovs_rpm_version" '{print $2}' | awk -F "/" '{print $2}')
	latest_ovs_ver="openvswitch-$ovs_rpm_version-$partial_latest_ovs_ver.$ovs_arch"
	repo_ovs_ver=$(yum provides openvswitch | grep -B1 puddle | head -n1 | awk '{print $1}')
	latest_openvswitch_rpm_url="http://$ovs_rpm_parent_location/$partial_latest_ovs_ver/$ovs_arch/$latest_ovs_ver.rpm"
	
	if [[ "$repo_ovs_ver" != "$latest_ovs_ver" ]]; then
		echo "The latest available OVS package ($latest_ovs_ver) needs to be tested"
		echo "Download latest package here: $latest_openvswitch_rpm_url"
	else
		echo "The repo version ($repo_ovs_ver) and latest available version ($latest_ovs_ver) are the same"
		echo "No need to test latest package at this time"
	fi
		
	rm -Rf $ovs_rpm_version
	popd
}
	
	
		
	if [[ -z "$partial_repo_ovs_rpm_version" ]]; then
		partial_repo_ovs_rpm_version=$(yum provides openvswitch | grep -B1 $current_ovs_repo | head -n1 | awk '{print $1}')
	fi	
	
	if [[ $(echo "$partial_repo_ovs_rpm_version" | grep "$ovs_arch") ]]; then
		repo_ovs_rpm_version=$partial_repo_ovs_rpm_version
	elif [[ ! $(echo "$partial_repo_ovs_rpm_version" | grep "$ovs_arch") ]]; then
		repo_ovs_rpm_version=openvswitch-$partial_repo_ovs_rpm_version.$ovs_arch
	elif [[ -z "$partial_repo_ovs_rpm_version" ]]; then
		echo "Could not find an openvswitch package associated with repo $current_ovs_repo"
	fi

	echo "Latest openvswitch test version is: $latest_ovs_ver"
	echo "Repo openvswitch test version is: $repo_ovs_rpm_version"

	if [[ $repo_ovs_rpm_version != $latest_ovs_ver ]]; then
		rlLog "The latest openvswitch package ($latest_ovs_ver) will also need to be tested"
		test_latest_openvswitch_package="yes"
	fi
	latest_openvswitch_rpm=http://$ovs_rpm_parent_location/$partial_latest_ovs_ver/$ovs_arch/$latest_ovs_ver.rpm
	popd
}



check_need_to_upgrade()
{
	if [[ $(yum provides openvswitch | grep -i "installed") ]]; then
		installed_openvswitch_package=$(yum provides openvswitch | grep -B1 -i "installed" | head -n1 | awk '{print $1}')
	elif [[ $(yum provides openvswitch | grep "@") ]]; then
		installed_openvswitch_package=$(yum provides openvswitch | grep -B1 -i "@" | head -n1 | awk '{print $1}')
	fi
	
	if [[ $install_latest_ovs_rpm == "yes" ]]; then
        check_latest_openvswitch_package
        if [[ "$latest_ovs_ver" == "$installed_openvswitch_package" ]]; then
        	echo "The target and installed versions are the same.  No need to upgrade"
        	need_to_upgrade="no"
        else
        	echo "Package upgrade is needed"
        	need_to_upgrade="yes"
        fi
        echo "Need to upgrade: $need_to_upgrade"
    else
    	local repo_ovs_version=$(yum provides openvswitch | grep -B1 -i $lp_test_type"-"$lp_target_version | head -n1 | awk '{print $1}')
    	if [[ "$repo_ovs_version" == "$installed_openvswitch_package" ]]; then
        	echo "The target and installed versions are the same.  No need to upgrade"
        	need_to_upgrade="no"
        else
        	recho "Package upgrade is needed"
        	need_to_upgrade="yes"
        fi
        echo "Need to upgrade: $need_to_upgrade"
    fi
}

check_need_to_upgrade
