get_dpdk_packages()
{
	$dbg_flag
	target_rhel_version=$1

	if [[ $2 ]]; then arch=$2; else arch=x86_64; fi
	x_tmp=$(curl -su : --negotiate  https://errata.devel.redhat.com/package/show/dpdk | grep $target_rhel_version.0 | head -n1)
	errata=$(curl -su : --negotiate  https://errata.devel.redhat.com/package/show/dpdk | grep -B1 "$x_tmp"| head -n1 | awk -F '"' '{print $(NF-1)}' | sed 's/\/advisory\///g')
	curl -su : --negotiate https://errata.devel.redhat.com/api/v1/erratum/$errata/builds | jq > ~/builds.txt
	build_id=$(grep "id" ~/builds.txt | awk '{print $NF}' | tr -d ,)
	curl -su : --negotiate https://brewweb.engineering.redhat.com/brew/buildinfo?buildID=$build_id > ~/builds2.txt
	export RPM_DPDK=$(grep $arch.rpm ~/builds2.txt | egrep -v 'devel|tools|debug' | awk -F '"' '{print $4}')
	export RPM_DPDK_TOOLS=$(grep $arch.rpm ~/builds2.txt | grep tools | awk -F '"' '{print $4}')
	if [[ -z $RPM_DPDK ]]; then
		echo "It appears that the $arch arch is not available"
		exit 1
	else
		echo "RPM_DPDK: $RPM_DPDK"
		echo "RPM_DPDK_TOOLS: $RPM_DPDK_TOOLS"
	fi
	rm -f ~/builds.txt ~/builds2.txt
}
