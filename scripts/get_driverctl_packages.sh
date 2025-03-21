#!/bin/bash

get_latest_driverctl()
{
    $dbg_flag
    download_server="download.devel.redhat.com"
    timeout 5s bash -c "curl -sL http://$download_server/brewroot/packages/driverctl" > /dev/null
    if [[ $? -ne 0 ]]; then
    	download_server="download.eng.bos.redhat.com"
    	timeout 5s bash -c "curl -sL http://$download_server/brewroot/packages/driverctl"
		if [[ $? -ne 0 ]]; then
			echo "The driverctl package download servers are unreachable"
			return 1
		fi
	fi    
    
	latest_build_id=$(curl -sL http://$download_server/brewroot/packages/driverctl | grep valign | tail -n1 | awk -F '"' '{print $8}' | tr -d '/')
	
	if [[ ! $(curl -sL http://$download_server/brewroot/packages/driverctl/$latest_build_id/ | grep el8) ]]; then
	    latest_build_id=$(curl -sL http://$download_server/brewroot/packages/driverctl | grep valign | tail -n2 | head -n1 | awk -F '"' '{print $8}' | tr -d '/')
	fi
	
	latest_el8_package_id=$(curl -sL http://$download_server/brewroot/packages/driverctl/$latest_build_id/ | grep el8 | head -n1 |  awk -F '"' '{print $8}' | tr -d '/')
	el8_rpm=$(curl -sL http://$download_server/brewroot/packages/driverctl/$latest_build_id/$latest_el8_package_id/noarch/ | grep rpm | awk -F '"' '{print $8}')
	
	echo "RHEL-8 URL: http://$download_server/brewroot/packages/driverctl/$latest_build_id/$latest_el8_package_id/noarch/$el8_rpm"	
	export DRIVERCTL_RHEL8="http://$download_server/brewroot/packages/driverctl/$latest_build_id/$latest_el8_package_id/noarch/$el8_rpm"
	
	if [[ ! $(curl -sL http://$download_server/brewroot/packages/driverctl/$latest_build_id/ | grep el9) ]]; then
	    latest_build_id=$(curl -sL http://download.devel.redhat.com/brewroot/packages/driverctl | grep valign | tail -n2 | head -n1 | awk -F '"' '{print $8}' | tr -d '/')
	fi    

	latest_el9_package_id=$(curl -sL http://$download_server/brewroot/packages/driverctl/$latest_build_id/ | grep el9 | head -n1 |  awk -F '"' '{print $8}' | tr -d '/')

	el9_rpm=$(curl -sL http://$download_server/brewroot/packages/driverctl/$latest_build_id/$latest_el9_package_id/noarch/ | grep rpm | awk -F '"' '{print $8}')	
	
	echo "RHEL-9 URL: http://$download_server/brewroot/packages/driverctl/$latest_build_id/$latest_el9_package_id/noarch/$el9_rpm"	
	export DRIVERCTL_RHEL9="http://$download_server/brewroot/packages/driverctl/$latest_build_id/$latest_el9_package_id/noarch/$el9_rpm"
}

get_latest_driverctl
