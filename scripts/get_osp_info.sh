#!/bin/bash

dbg_flag=${dbg_flag:-"set +x"}
$dbg_flag

osp_version=$1
repo_option=$2 # valid repo options are "cdn" or "puddle" with cdn being the default if no repo option is provided
if [[ ! -s /usr/bin/rhos-release_orig ]]; then
	cp /usr/bin/rhos-release /usr/bin/rhos-release_orig
elif [[ -s /usr/bin/rhos-release_orig ]]; then
	/bin/cp -f /usr/bin/rhos-release_orig /usr/bin/rhos-release
fi

sedeasy ()
{
	sed -i "s/$(echo $1 | sed -e 's/\([[\/.*]\|\]\)/\\&/g')/$(echo $2 | sed -e 's/[\/&]/\\&/g')/g" $3
} 

if [[ ! $(rpm -q rhos-release-latest.noarch.rpm) ]]; then
	yum localinstall -y http://download.lab.bos.redhat.com/rcm-guest/puddles/OpenStack/rhos-release/rhos-release-latest.noarch.rpm
fi
rm -f /etc/yum.repos.d/rhos-*.repo

if [[ $# -lt 2 ]] || [[ $2 == "cdn" ]]; then
	option="CDN"	
	current_latest_rhosp_value=$(grep 'LATEST_OSP=' /usr/bin/rhos-release | awk -F "=" '{print $2}')
	sedeasy "LATEST_OSP=$current_latest_rhosp_value" "LATEST_OSP=$osp_version" /usr/bin/rhos-release
	rhos-release latest-released > /dev/null
elif [[ $2 == "puddle" ]]; then
	option="Puddle"
	rhos-release -x $osp_version > /dev/null
fi

echo "Gathering openvswitch package information for RHOSP $osp_version $option.  This may take a couple of minutes..."

yum clean all expire-cache > /dev/null

ovs_sel_pkg=$(yum provides openvswitch-selinux-extra-policy | tail -n6 | head -n1 | tr -d "[:cntrl:]" | awk '{print $1}')

check_ovs_pkg()
{
	$dbg_flag
	if [[ ! -z $ovs_pkg ]]; then
		return 0
	fi
}
get_ovs_pkg_info()
{
	$dbg_flag
	ovs_pkg=$(yum provides openvswitch | tail -n5 | head -n1 | tr -d "[:cntrl:]" | awk '{print $1}')
	if [[ ! -z $ovs_pkg ]] && [[ ! $(yum provides openvswitch | grep Wrapper) ]]; then
		return 0
	elif [[ -z $ovs_pkg ]]; then
		ovs_pkg=$(yum provides openvswitch2.10 | tail -n5 | head -n1 | tr -d "[:cntrl:]" | awk '{print $1}')
		check_ovs_pkg
	elif [[ -z $ovs_pkg ]]; then
		ovs_pkg=$(yum provides openvswitch2.11 | tail -n5 | head -n1 | tr -d "[:cntrl:]" | awk '{print $1}')
		check_ovs_pkg
	elif [[ -z $ovs_pkg ]]; then
		ovs_pkg=$(yum provides openvswitch2.12 | tail -n5 | head -n1 | tr -d "[:cntrl:]" | awk '{print $1}')
		check_ovs_pkg
	elif [[ -z $ovs_pkg ]]; then
		ovs_pkg=$(yum provides openvswitch2.13 | tail -n5 | head -n1 | tr -d "[:cntrl:]" | awk '{print $1}')
		check_ovs_pkg
	fi
}

get_ovs_pkg_info

echo "*********************************************************************"
echo "openvswitch package for RHOSP $osp_version $option: $ovs_pkg"
echo "openvswitch-selinux-extra-policy for RHOSP $osp_version $option: $ovs_sel_pkg"
echo "*********************************************************************"

