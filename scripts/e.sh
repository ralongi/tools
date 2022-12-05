get_dpdk_package_versions_vm()
{
	$dbg_flag	
	local target_vm=$1
	if [[ $# -lt 1 ]]; then
		echo "Please provide the required VM name"
		return 1
	fi
	
	rpm -q dos2unix
	if [[ $? -ne 0 ]]; then dnf -y install dos2unix; fi
	export RPM_DPDK_VM=""
	export RPM_DPDK_TOOLS_VM=""
	export vm_rhel_version=""
	vmsh run_cmd $target_vm "cut -f1 -d. /etc/redhat-release | sed 's/[^0-9]//g'" | tee /tmp/vm_rhel_version.txt
	sleep 1
	dos2unix -f /tmp/vm_rhel_version.txt
	sleep 1
	local vm_rhel_version=$(grep --color=never -A1 cut /tmp/vm_rhel_version.txt | tail -n1)
	local vm_rhel_version=$(echo $vm_rhel_version | tr -d '[{cntrl:]')
	local vm_rhel_version=$(printf $vm_rhel_version)
	vmsh run_cmd $target_vm "cat /etc/os-release" | tee /tmp/vm_version_id.txt
	sleep 1
	dos2unix -f /tmp/vm_version_id.txt
	sleep 1
	local VERSION_ID=$(grep --color=never VERSION_ID /tmp/vm_version_id.txt | awk -F '"' '{print $2}' | tr -d '[:cntrl:]')
	local VERSION_ID=$(echo $VERSION_ID | tr -d '[{cntrl:]')
	local VERSION_ID=$(printf $VERSION_ID)	
	
	if [[ $vm_rhel_version == "7" ]]; then
		export RPM_DPDK_VM=http://download.hosts.prod.psi.bos.redhat.com/brewroot/packages/dpdk/18.11.8/1.el7_8/x86_64/dpdk-18.11.8-1.el7_8.x86_64.rpm
		export RPM_DPDK_TOOLS_VM=http://download.hosts.prod.psi.bos.redhat.com/brewroot/packages/dpdk/18.11.8/1.el7_8/x86_64/dpdk-tools-18.11.8-1.el7_8.x86_64.rpm		
	elif [[ $VERSION_ID == "8.2" ]]; then
		export RPM_DPDK_VM=http://download.hosts.prod.psi.bos.redhat.com/brewroot/packages/dpdk/19.11/5.el8_2/x86_64/dpdk-19.11-5.el8_2.x86_64.rpm
		export RPM_DPDK_TOOLS_VM=http://download.hosts.prod.psi.bos.redhat.com/brewroot/packages/dpdk/19.11/5.el8_2/x86_64/dpdk-tools-19.11-5.el8_2.x86_64.rpm
	elif [[ $VERSION_ID == "8.3" ]]; then
		export RPM_DPDK_VM=http://download.hosts.prod.psi.bos.redhat.com/brewroot/packages/dpdk/19.11.3/1.el8/x86_64/dpdk-19.11.3-1.el8.x86_64.rpm
		export RPM_DPDK_TOOLS_VM=http://download.hosts.prod.psi.bos.redhat.com/brewroot/packages/dpdk/19.11.3/1.el8/x86_64/dpdk-tools-19.11.3-1.el8.x86_64.rpm
	elif [[ $VERSION_ID == "8.4" ]]; then
		export RPM_DPDK_VM=http://download.hosts.prod.psi.bos.redhat.com/brewroot/packages/dpdk/20.11/3.el8/x86_64/dpdk-20.11-3.el8.x86_64.rpm
		export RPM_DPDK_TOOLS_VM=http://download.hosts.prod.psi.bos.redhat.com/brewroot/packages/dpdk/20.11/3.el8/x86_64/dpdk-tools-20.11-3.el8.x86_64.rpm
	# use 8.4 packages for RHEL-8.5 until updated info is available on https://errata.devel.redhat.com/package/show/dpdk
	elif [[ $VERSION_ID == "8.5" ]]; then
		export RPM_DPDK_VM=http://download.hosts.prod.psi.bos.redhat.com/brewroot/packages/dpdk/20.11/3.el8/x86_64/dpdk-20.11-3.el8.x86_64.rpm
		export RPM_DPDK_TOOLS_VM=http://download.hosts.prod.psi.bos.redhat.com/brewroot/packages/dpdk/20.11/3.el8/x86_64/dpdk-tools-20.11-3.el8.x86_64.rpm
	elif [[ $VERSION_ID == "8.6" ]]; then
		export RPM_DPDK_VM=http://download.hosts.prod.psi.bos.redhat.com/brewroot/packages/dpdk/21.11/1.el8/x86_64/dpdk-21.11-1.el8.x86_64.rpm
		export RPM_DPDK_TOOLS_VM=http://download.hosts.prod.psi.bos.redhat.com/brewroot/packages/dpdk/21.11/1.el8/x86_64/dpdk-tools-21.11-1.el8.x86_64.rpm
	elif [[ $VERSION_ID == "9.0" ]]; then
		export RPM_DPDK_VM=http://download.hosts.prod.psi.bos.redhat.com/brewroot/packages/dpdk/21.11/1.el9_0/x86_64/dpdk-21.11-1.el9_0.x86_64.rpm
		export RPM_DPDK_TOOLS_VM=http://download.hosts.prod.psi.bos.redhat.com/brewroot/packages/dpdk/21.11/1.el9_0/x86_64/dpdk-tools-21.11-1.el9_0.x86_64.rpm
	elif [[ $vm_rhel_version == 8 ]]; then
		export RPM_DPDK_VM=http://download.hosts.prod.psi.bos.redhat.com/brewroot/packages/dpdk/20.11/3.el8/x86_64/dpdk-20.11-3.el8.x86_64.rpm
		export RPM_DPDK_TOOLS_VM=http://download.hosts.prod.psi.bos.redhat.com/brewroot/packages/dpdk/20.11/3.el8/x86_64/dpdk-tools-20.11-3.el8.x86_64.rpm
	elif [[ $vm_rhel_version == 9 ]]; then
		export RPM_DPDK_VM=http://download.hosts.prod.psi.bos.redhat.com/brewroot/packages/dpdk/21.11/1.el9_0/x86_64/dpdk-21.11-1.el9_0.x86_64.rpm
		export RPM_DPDK_TOOLS_VM=http://download.hosts.prod.psi.bos.redhat.com/brewroot/packages/dpdk/21.11/1.el9_0/x86_64/dpdk-tools-21.11-1.el9_0.x86_64.rpm
	fi

	echo "VM VERSION_ID: $VERSION_ID"
	echo "VM RHEL Version: $vm_rhel_version"
	echo "RPM_DPDK_VM=$RPM_DPDK_VM"
	echo "RPM_DPDK_TOOLS_VM=$RPM_DPDK_TOOLS_VM"
}
