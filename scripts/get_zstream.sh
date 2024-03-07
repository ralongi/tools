function get_zinfo(){

	wget -O /tmp/ZConfig.yaml -q https://gitlab.cee.redhat.com/kernel-qe/core-kernel/kernel-general/-/raw/master/Sustaining/ZConfig.yaml?inline=false 

	version=$1
	ver=$(echo $version | cut -d "-" -f 2 )
	search=$(echo "${ver//.}")z
	distro=$(cat /tmp/ZConfig.yaml | grep $search -A 30 | grep distro -A 1 | grep RHEL)
	kernel=$(cat /tmp/ZConfig.yaml | grep $search -A 30 | grep version -A 1 | grep kernel)
	echo "DISTRO=" $distro
	echo "KERNEL=" $kernel
	rm -f /tmp/ZConfig.yaml
}

if [[ $# -ne 1 ]]; then
	echo "You must specify RHEL to check for z stream info"
	echo "USAGE: zinfo.sh RHEL-7.8"
else
	get_zinfo $1
fi

