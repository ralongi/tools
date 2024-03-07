#! /bin/bash

# Script to update package_list.sh
# Script reads /home/ralongi/github/tools/scripts/fdp_errata_list.txt so be sure to update that file with the correct errata info before running script

dbg_flag=${dbg_flag:-"set +x"}
$dbg_flag
script_directory=~/git/kernel/networking/common/tools
#checkin_git=${checkin_git:-"no"}
fdp_release=$1
if [[ $# -lt 1 ]]; then echo "Please provide FDP release (21I, 21j, etc):"; read fdp_release; fi
fdp_release=$(echo "$fdp_release" | awk '{print toupper($0)}')
new_package_template_file="/home/ralongi/github/tools/scripts/new_package_list_template.sh"
new_package_list_temp_file="/home/ralongi/temp/new_package_list_temp.sh"
new_package_list_file="/home/ralongi/temp/new_package_list.sh"
fdp_errata_list_file=/home/ralongi/github/tools/scripts/fdp_errata_list.txt

#while true; do
#    read -p "Have you confirmed that $fdp_errata_list_file has the correct information and have you run kinit?" yn
#    case $yn in
#        [Yy]* ) break;;
#        [Nn]* ) exit;;
#        * ) echo "Please answer yes or no.";;
#    esac
#done

sedeasy ()
{
sed -i "s/$(echo $1 | sed -e 's/\([[\/.*]\|\]\)/\\&/g')/$(echo $2 | sed -e 's/[\/&]/\\&/g')/g" $3
}

rm -f ~/temp/builds.txt
rm -f $new_package_list_temp_file $new_package_list_file
echo "" >> $new_package_list_file
echo "# FDP $fdp_release Packages" >> $new_package_list_file

pushd $script_directory

selinux_version=$(curl -sL http://download.hosts.prod.psi.bos.redhat.com/brewroot/packages/openvswitch-selinux-extra-policy/1.0/ | grep el7 | tail -n1 | awk -F '>' '{print $6}' | awk -F '"' '{print $2}' | tr -d /)
package_url=http://download.hosts.prod.psi.bos.redhat.com/brewroot/packages/openvswitch-selinux-extra-policy/1.0/$selinux_version/noarch/openvswitch-selinux-extra-policy-1.0-$selinux_version.noarch.rpm
http_code=$(curl --silent --head --write-out '%{http_code}' "$package_url" | grep HTTP | awk '{print $2}')
if [[ "$http_code" -ne 200 ]]; then echo "$package_url is NOT a valid link.  Exiting..."; exit 1; fi
echo "OVS_SELINUX_$fdp_release"_RHEL7=${package_url} >> $new_package_list_file
echo ""
echo OVS_SELINUX_$fdp_release"_RHEL7 package location: $package_url"
echo ""

selinux_version=$(curl -sL http://download.hosts.prod.psi.bos.redhat.com/brewroot/packages/openvswitch-selinux-extra-policy/1.0/ | grep el8 | tail -n1 | awk -F '>' '{print $6}' | awk -F '"' '{print $2}' | tr -d /)
package_url=http://download.hosts.prod.psi.bos.redhat.com/brewroot/packages/openvswitch-selinux-extra-policy/1.0/$selinux_version/noarch/openvswitch-selinux-extra-policy-1.0-$selinux_version.noarch.rpm
http_code=$(curl --silent --head --write-out '%{http_code}' "$package_url" | grep HTTP | awk '{print $2}')
if [[ "$http_code" -ne 200 ]]; then echo "$package_url is NOT a valid link.  Exiting..."; exit 1; fi
echo "OVS_SELINUX_$fdp_release"_RHEL8=${package_url} >> $new_package_list_file
echo ""
echo OVS_SELINUX_$fdp_release"_RHEL8 package location: $package_url"
echo ""

selinux_version=$(curl -sL http://download.hosts.prod.psi.bos.redhat.com/brewroot/packages/openvswitch-selinux-extra-policy/1.0/ | grep el9 | tail -n1 | awk -F '>' '{print $6}' | awk -F '"' '{print $2}' | tr -d /)
package_url=http://download.hosts.prod.psi.bos.redhat.com/brewroot/packages/openvswitch-selinux-extra-policy/1.0/$selinux_version/noarch/openvswitch-selinux-extra-policy-1.0-$selinux_version.noarch.rpm
http_code=$(curl --silent --head --write-out '%{http_code}' "$package_url" | grep HTTP | awk '{print $2}')
if [[ "$http_code" -ne 200 ]]; then echo "$package_url is NOT a valid link.  Exiting..."; exit 1; fi
echo "OVS_SELINUX_$fdp_release"_RHEL9=${package_url} >> $new_package_list_file
echo ""
echo OVS_SELINUX_$fdp_release"_RHEL9 package location: $package_url"
echo ""

errata=$(grep 'OVS-2.13 RHEL-7' $fdp_errata_list_file | awk '{print $3}')
if [[ -z $errata ]]; then
	echo "No errata provided so OVS 2.13 RHEL-7 package will not be added for FDP $fdp_release"
	echo ""
else
	./get_errata_packages.sh -e $errata
	curl -su : --negotiate https://errata.devel.redhat.com/api/v1/erratum/$errata/builds | jq > ~/temp/builds.txt
	build=$(grep -A8 '"x86_64": \[' ~/temp/builds.txt | egrep -v 'scripts|devel|ipsec|debugsource|debuginfo|\[' | head -n1 | awk -F '"' '{print $2}')
	build_id=$(echo $build | awk -F - '{print $NF}' | awk -F ".el8" '{print $1}')
	python_package=$(grep -A8 '"x86_64": \[' ~/temp/builds.txt | egrep -v 'scripts|devel|ipsec|debugsource|debuginfo|\[' | grep -i python | awk -F '"' '{print $2}')
	http_code=$(curl --silent --head --write-out '%{http_code}' "$package_url" | grep HTTP | awk '{print $2}')
	if [[ "$http_code" -ne 200 ]]; then echo "$package_url is NOT a valid link.  Exiting..."; exit 1; fi
	echo "OVS213_$fdp_release"_RHEL7=${package_url} >> $new_package_list_file
	echo ""
	echo OVS213_$fdp_release"_RHEL7 package location: $package_url"
	echo ""
fi

errata=$(grep 'OVS-2.13 RHEL-8' $fdp_errata_list_file | awk '{print $3}')
if [[ -z $errata ]]; then
	echo "No errata provided so OVS 2.13 RHEL-8 package will not be added for FDP $fdp_release"
	echo ""
else
	./get_errata_packages.sh -e $errata ~/temp/builds.txt
	egrep -v 'scripts|devel|ipsec|debugsource|debuginfo' ~/temp/builds.txt
	build=$(egrep -v 'scripts|devel|ipsec|debugsource|debuginfo' ~/temp/builds.txt | egrep -v 'test|python')
	curl -su : --negotiate https://errata.devel.redhat.com/api/v1/erratum/$errata/builds | jq > ~/temp/builds.txt
	build=$(grep -A8 '"x86_64": \[' ~/temp/builds.txt | egrep -v 'scripts|devel|ipsec|debugsource|debuginfo|\[' | head -n1 | awk -F '"' '{print $2}')
	build_id=$(echo $build | awk -F - '{print $NF}' | awk -F ".el8" '{print $1}')
	python_package=$(grep -A8 '"x86_64": \[' ~/temp/builds.txt | egrep -v 'scripts|devel|ipsec|debugsource|debuginfo|\[' | grep -i python | awk -F '"' '{print $2}')
	tcpdump_package=$(grep -A1 '"noarch": \[' ~/temp/builds.txt | tail -n1 | awk -F '"' '{print $2}')
	package_url="http://download.hosts.prod.psi.bos.redhat.com/brewroot/packages/openvswitch2.13/2.13.0/$build_id.el8fdp/x86_64/$build"
	python_package_url="http://download.hosts.prod.psi.bos.redhat.com/brewroot/packages/openvswitch2.13/2.13.0/$build_id.el8fdp/x86_64/$python_package"
	tcpdump_package_url="http://download.hosts.prod.psi.bos.redhat.com/brewroot/packages/openvswitch2.13/2.13.0/$build_id.el8fdp/noarch/$tcpdump_package"
	http_code=$(curl --silent --head --write-out '%{http_code}' "$package_url" | grep HTTP | awk '{print $2}')
	if [[ "$http_code" -ne 200 ]]; then echo "$package_url is NOT a valid link.  Exiting..."; exit 1; fi
	http_code=$(curl --silent --head --write-out '%{http_code}' "$python_package_url" | grep HTTP | awk '{print $2}')
	if [[ "$http_code" -ne 200 ]]; then echo "$python_package_url is NOT a valid link.  Exiting..."; exit 1; fi
	http_code=$(curl --silent --head --write-out '%{http_code}' "$tcpdump_package_url" | grep HTTP | awk '{print $2}')
	if [[ "$http_code" -ne 200 ]]; then echo "$tcpdump_package_url is NOT a valid link.  Exiting..."; exit 1; fi
	echo "OVS213_$fdp_release"_RHEL8=${package_url} >> $new_package_list_file
	echo "OVS213_PYTHON_$fdp_release"_RHEL8=${python_package_url} >> $new_package_list_file
	echo "OVS213_TCPDUMP_$fdp_release"_RHEL8=${tcpdump_package_url} >> $new_package_list_file
	echo ""
	echo OVS213_$fdp_release"_RHEL8 package location: $package_url"
	echo OVS213_PYTHON_$fdp_release"_RHEL8 package location: $python_package_url"
	echo OVS213_TCPDUMP_$fdp_release"_RHEL8 package location: $tcpdump_package_url"
	echo ""
fi

errata=$(grep 'OVS-2.15 RHEL-8' $fdp_errata_list_file | awk '{print $3}')
if [[ -z $errata ]]; then
	echo "No errata provided so OVS 2.15 RHEL-8 package will not be added for FDP $fdp_release"
	echo ""
else
	curl -su : --negotiate https://errata.devel.redhat.com/api/v1/erratum/$errata/builds | jq > ~/temp/builds.txt
	build=$(grep -A8 '"x86_64": \[' ~/temp/builds.txt | egrep -v 'scripts|devel|ipsec|debugsource|debuginfo|\[' | head -n1 | awk -F '"' '{print $2}')
	build_id=$(echo $build | awk -F - '{print $NF}' | awk -F ".el8" '{print $1}')
	python_package=$(grep -A8 '"x86_64": \[' ~/temp/builds.txt | egrep -v 'scripts|devel|ipsec|debugsource|debuginfo|\[' | grep -i python | awk -F '"' '{print $2}')
	tcpdump_package=$(grep -A1 '"noarch": \[' ~/temp/builds.txt | tail -n1 | awk -F '"' '{print $2}')
	package_url="http://download.hosts.prod.psi.bos.redhat.com/brewroot/packages/openvswitch2.15/2.15.0/$build_id.el8fdp/x86_64/$build"
	python_package_url="http://download.hosts.prod.psi.bos.redhat.com/brewroot/packages/openvswitch2.15/2.15.0/$build_id.el8fdp/x86_64/$python_package"
	tcpdump_package_url="http://download.hosts.prod.psi.bos.redhat.com/brewroot/packages/openvswitch2.15/2.15.0/$build_id.el8fdp/noarch/$tcpdump_package"
	http_code=$(curl --silent --head --write-out '%{http_code}' "$package_url" | grep HTTP | awk '{print $2}')
	if [[ "$http_code" -ne 200 ]]; then echo "$package_url is NOT a valid link.  Exiting..."; exit 1; fi
	http_code=$(curl --silent --head --write-out '%{http_code}' "$python_package_url" | grep HTTP | awk '{print $2}')
	if [[ "$http_code" -ne 200 ]]; then echo "$python_package_url is NOT a valid link.  Exiting..."; exit 1; fi
	http_code=$(curl --silent --head --write-out '%{http_code}' "$tcpdump_package_url" | grep HTTP | awk '{print $2}')
	if [[ "$http_code" -ne 200 ]]; then echo "$tcpdump_package_url is NOT a valid link.  Exiting..."; exit 1; fi
	echo "OVS215_$fdp_release"_RHEL8=${package_url} >> $new_package_list_file
	echo "OVS215_PYTHON_$fdp_release"_RHEL8=${python_package_url} >> $new_package_list_file
	echo "OVS215_TCPDUMP_$fdp_release"_RHEL8=${tcpdump_package_url} >> $new_package_list_file
	echo ""
	echo OVS215_$fdp_release"_RHEL8 package location: $package_url"
	echo OVS215_PYTHON_$fdp_release"_RHEL8 package location: $python_package_url"
	echo OVS215_TCPDUMP_$fdp_release"_RHEL8 package location: $tcpdump_package_url"
	echo ""
fi

errata=$(grep 'OVS-2.16 RHEL-8' $fdp_errata_list_file | awk '{print $3}')
if [[ -z $errata ]]; then
	echo "No errata provided so OVS 2.16 RHEL-8 package will not be added for FDP $fdp_release"
	echo ""
else
	curl -su : --negotiate https://errata.devel.redhat.com/api/v1/erratum/$errata/builds | jq > ~/temp/builds.txt
	build=$(grep -A8 '"x86_64": \[' ~/temp/builds.txt | egrep -v 'scripts|devel|ipsec|debugsource|debuginfo|\[' | head -n1 | awk -F '"' '{print $2}')
	build_id=$(echo $build | awk -F - '{print $NF}' | awk -F ".el8" '{print $1}')
	python_package=$(grep -A8 '"x86_64": \[' ~/temp/builds.txt | egrep -v 'scripts|devel|ipsec|debugsource|debuginfo|\[' | grep -i python | awk -F '"' '{print $2}')
	tcpdump_package=$(grep -A1 '"noarch": \[' ~/temp/builds.txt | tail -n1 | awk -F '"' '{print $2}')
	package_url="http://download.hosts.prod.psi.bos.redhat.com/brewroot/packages/openvswitch2.16/2.16.0/$build_id.el8fdp/x86_64/$build"
	python_package_url="http://download.hosts.prod.psi.bos.redhat.com/brewroot/packages/openvswitch2.16/2.16.0/$build_id.el8fdp/x86_64/$python_package"
	tcpdump_package_url="http://download.hosts.prod.psi.bos.redhat.com/brewroot/packages/openvswitch2.16/2.16.0/$build_id.el8fdp/noarch/$tcpdump_package"
	http_code=$(curl --silent --head --write-out '%{http_code}' "$package_url" | grep HTTP | awk '{print $2}')
	if [[ "$http_code" -ne 200 ]]; then echo "$package_url is NOT a valid link.  Exiting..."; exit 1; fi
	http_code=$(curl --silent --head --write-out '%{http_code}' "$python_package_url" | grep HTTP | awk '{print $2}')
	if [[ "$http_code" -ne 200 ]]; then echo "$python_package_url is NOT a valid link.  Exiting..."; exit 1; fi
	http_code=$(curl --silent --head --write-out '%{http_code}' "$tcpdump_package_url" | grep HTTP | awk '{print $2}')
	if [[ "$http_code" -ne 200 ]]; then echo "$tcpdump_package_url is NOT a valid link.  Exiting..."; exit 1; fi
	echo "OVS216_$fdp_release"_RHEL8=${package_url} >> $new_package_list_file
	echo "OVS216_PYTHON_$fdp_release"_RHEL8=${python_package_url} >> $new_package_list_file
	echo "OVS216_TCPDUMP_$fdp_release"_RHEL8=${tcpdump_package_url} >> $new_package_list_file
	echo ""
	echo OVS216_$fdp_release"_RHEL8 package location: $package_url"
	echo OVS216_PYTHON_$fdp_release"_RHEL8 package location: $python_package_url"
	echo OVS216_TCPDUMP_$fdp_release"_RHEL8 package location: $tcpdump_package_url"
	echo ""
fi

errata=$(grep 'OVS-2.17 RHEL-8' $fdp_errata_list_file | awk '{print $3}')
if [[ -z $errata ]]; then
	echo "No errata provided so OVS 2.17 RHEL-8 package will not be added for FDP $fdp_release"
	echo ""
else
	curl -su : --negotiate https://errata.devel.redhat.com/api/v1/erratum/$errata/builds | jq > ~/temp/builds.txt
	build=$(grep -A8 '"x86_64": \[' ~/temp/builds.txt | egrep -v 'scripts|devel|ipsec|debugsource|debuginfo|\[' | head -n1 | awk -F '"' '{print $2}')
	build_id=$(echo $build | awk -F - '{print $NF}' | awk -F ".el8" '{print $1}')
	python_package=$(grep -A8 '"x86_64": \[' ~/temp/builds.txt | egrep -v 'scripts|devel|ipsec|debugsource|debuginfo|\[' | grep -i python | awk -F '"' '{print $2}')
	tcpdump_package=$(grep -A1 '"noarch": \[' ~/temp/builds.txt | tail -n1 | awk -F '"' '{print $2}')
	package_url="http://download.hosts.prod.psi.bos.redhat.com/brewroot/packages/openvswitch2.17/2.17.0/$build_id.el8fdp/x86_64/$build"
	python_package_url="http://download.hosts.prod.psi.bos.redhat.com/brewroot/packages/openvswitch2.17/2.17.0/$build_id.el8fdp/x86_64/$python_package"
	tcpdump_package_url="http://download.hosts.prod.psi.bos.redhat.com/brewroot/packages/openvswitch2.17/2.17.0/$build_id.el8fdp/noarch/$tcpdump_package"
	http_code=$(curl --silent --head --write-out '%{http_code}' "$package_url" | grep HTTP | awk '{print $2}')
	if [[ "$http_code" -ne 200 ]]; then echo "$package_url is NOT a valid link.  Exiting..."; exit 1; fi
	http_code=$(curl --silent --head --write-out '%{http_code}' "$python_package_url" | grep HTTP | awk '{print $2}')
	if [[ "$http_code" -ne 200 ]]; then echo "$python_package_url is NOT a valid link.  Exiting..."; exit 1; fi
	http_code=$(curl --silent --head --write-out '%{http_code}' "$tcpdump_package_url" | grep HTTP | awk '{print $2}')
	if [[ "$http_code" -ne 200 ]]; then echo "$tcpdump_package_url is NOT a valid link.  Exiting..."; exit 1; fi
	echo "OVS217_$fdp_release"_RHEL8=${package_url} >> $new_package_list_file
	echo "OVS217_PYTHON_$fdp_release"_RHEL8=${python_package_url} >> $new_package_list_file
	echo "OVS217_TCPDUMP_$fdp_release"_RHEL8=${tcpdump_package_url} >> $new_package_list_file
	echo ""
	echo OVS217_$fdp_release"_RHEL8 package location: $package_url"
	echo OVS217_PYTHON_$fdp_release"_RHEL8 package location: $python_package_url"
	echo OVS217_TCPDUMP_$fdp_release"_RHEL8 package location: $tcpdump_package_url"
	echo ""
fi

errata=$(grep 'OVS-3.10 RHEL-8' $fdp_errata_list_file | awk '{print $3}')
if [[ -z $errata ]]; then
	echo "No errata provided so OVS 3.10 RHEL-8 package will not be added for FDP $fdp_release"
	echo ""
else
	curl -su : --negotiate https://errata.devel.redhat.com/api/v1/erratum/$errata/builds | jq > ~/temp/builds.txt
	build=$(grep -A8 '"x86_64": \[' ~/temp/builds.txt | egrep -v 'scripts|devel|ipsec|debugsource|debuginfo|\[' | head -n1 | awk -F '"' '{print $2}')
	build_id=$(echo $build | awk -F - '{print $NF}' | awk -F ".el8" '{print $1}')
	python_package=$(grep -A8 '"x86_64": \[' ~/temp/builds.txt | egrep -v 'scripts|devel|ipsec|debugsource|debuginfo|\[' | grep -i python | awk -F '"' '{print $2}')
	tcpdump_package=$(grep -A1 '"noarch": \[' ~/temp/builds.txt | tail -n1 | awk -F '"' '{print $2}')
	package_url="http://download.hosts.prod.psi.bos.redhat.com/brewroot/packages/openvswitch3.1/3.1.0/$build_id.el8fdp/x86_64/$build"
	python_package_url="http://download.hosts.prod.psi.bos.redhat.com/brewroot/packages/openvswitch3.1/3.1.0/$build_id.el8fdp/x86_64/$python_package"
	tcpdump_package_url="http://download.hosts.prod.psi.bos.redhat.com/brewroot/packages/openvswitch3.1/3.1.0/$build_id.el8fdp/noarch/$tcpdump_package"
	http_code=$(curl --silent --head --write-out '%{http_code}' "$package_url" | grep HTTP | awk '{print $2}')
	if [[ "$http_code" -ne 200 ]]; then echo "$package_url is NOT a valid link.  Exiting..."; exit 1; fi
	http_code=$(curl --silent --head --write-out '%{http_code}' "$python_package_url" | grep HTTP | awk '{print $2}')
	if [[ "$http_code" -ne 200 ]]; then echo "$python_package_url is NOT a valid link.  Exiting..."; exit 1; fi
	http_code=$(curl --silent --head --write-out '%{http_code}' "$tcpdump_package_url" | grep HTTP | awk '{print $2}')
	if [[ "$http_code" -ne 200 ]]; then echo "$tcpdump_package_url is NOT a valid link.  Exiting..."; exit 1; fi
	echo "OVS310_$fdp_release"_RHEL8=${package_url} >> $new_package_list_file
	echo "OVS310_PYTHON_$fdp_release"_RHEL8=${python_package_url} >> $new_package_list_file
	echo "OVS310_TCPDUMP_$fdp_release"_RHEL8=${tcpdump_package_url} >> $new_package_list_file
	echo ""
	echo OVS310_$fdp_release"_RHEL8 package location: $package_url"
	echo OVS310_PYTHON_$fdp_release"_RHEL8 package location: $python_package_url"
	echo OVS310_TCPDUMP_$fdp_release"_RHEL8 package location: $tcpdump_package_url"
	echo ""
fi

errata=$(grep 'OVS-2.15 RHEL-9' $fdp_errata_list_file | awk '{print $3}')
if [[ -z $errata ]]; then
	echo "No errata provided so OVS 2.15 RHEL-9 package will not be added for FDP $fdp_release"
	echo ""
else
	curl -su : --negotiate https://errata.devel.redhat.com/api/v1/erratum/$errata/builds | jq > ~/temp/builds.txt
	build=$(grep -A8 '"x86_64": \[' ~/temp/builds.txt | egrep -v 'scripts|devel|ipsec|debugsource|debuginfo|\[' | head -n1 | awk -F '"' '{print $2}')
	build_id=$(echo $build | awk -F - '{print $NF}' | awk -F ".el9" '{print $1}')
	python_package=$(grep -A8 '"x86_64": \[' ~/temp/builds.txt | egrep -v 'scripts|devel|ipsec|debugsource|debuginfo|\[' | grep -i python | awk -F '"' '{print $2}')
	tcpdump_package=$(grep -A1 '"noarch": \[' ~/temp/builds.txt | tail -n1 | awk -F '"' '{print $2}')
	package_url="http://download.hosts.prod.psi.bos.redhat.com/brewroot/packages/openvswitch2.15/2.15.0/$build_id.el9fdp/x86_64/$build"
	python_package_url="http://download.hosts.prod.psi.bos.redhat.com/brewroot/packages/openvswitch2.15/2.15.0/$build_id.el9fdp/x86_64/$python_package"
	tcpdump_package_url="http://download.hosts.prod.psi.bos.redhat.com/brewroot/packages/openvswitch2.15/2.15.0/$build_id.el9fdp/noarch/$tcpdump_package"
	http_code=$(curl --silent --head --write-out '%{http_code}' "$package_url" | grep HTTP | awk '{print $2}')
	if [[ "$http_code" -ne 200 ]]; then echo "$package_url is NOT a valid link.  Exiting..."; exit 1; fi
	http_code=$(curl --silent --head --write-out '%{http_code}' "$python_package_url" | grep HTTP | awk '{print $2}')
	if [[ "$http_code" -ne 200 ]]; then echo "$python_package_url is NOT a valid link.  Exiting..."; exit 1; fi
	http_code=$(curl --silent --head --write-out '%{http_code}' "$tcpdump_package_url" | grep HTTP | awk '{print $2}')
	if [[ "$http_code" -ne 200 ]]; then echo "$tcpdump_package_url is NOT a valid link.  Exiting..."; exit 1; fi
	echo "OVS215_$fdp_release"_RHEL9=${package_url} >> $new_package_list_file
	echo "OVS215_PYTHON_$fdp_release"_RHEL9=${python_package_url} >> $new_package_list_file
	echo "OVS215_TCPDUMP_$fdp_release"_RHEL9=${tcpdump_package_url} >> $new_package_list_file
	echo ""
	echo OVS215_$fdp_release"_RHEL9 package location: $package_url"
	echo OVS215_PYTHON_$fdp_release"_RHEL9 package location: $python_package_url"
	echo OVS215_TCPDUMP_$fdp_release"_RHEL9 package location: $tcpdump_package_url"
	echo ""
fi

errata=$(grep 'OVS-2.17 RHEL-9' $fdp_errata_list_file | awk '{print $3}')
if [[ -z $errata ]]; then
	echo "No errata provided so OVS 2.17 RHEL-9 package will not be added for FDP $fdp_release"
	echo ""
else
	curl -su : --negotiate https://errata.devel.redhat.com/api/v1/erratum/$errata/builds | jq > ~/temp/builds.txt
	build=$(grep -A8 '"x86_64": \[' ~/temp/builds.txt | egrep -v 'scripts|devel|ipsec|debugsource|debuginfo|\[' | head -n1 | awk -F '"' '{print $2}')
	build_id=$(echo $build | awk -F - '{print $NF}' | awk -F ".el9" '{print $1}')
	python_package=$(grep -A8 '"x86_64": \[' ~/temp/builds.txt | egrep -v 'scripts|devel|ipsec|debugsource|debuginfo|\[' | grep -i python | awk -F '"' '{print $2}')
	tcpdump_package=$(grep -A1 '"noarch": \[' ~/temp/builds.txt | tail -n1 | awk -F '"' '{print $2}')
	package_url="http://download.hosts.prod.psi.bos.redhat.com/brewroot/packages/openvswitch2.17/2.17.0/$build_id.el9fdp/x86_64/$build"
	python_package_url="http://download.hosts.prod.psi.bos.redhat.com/brewroot/packages/openvswitch2.17/2.17.0/$build_id.el9fdp/x86_64/$python_package"
	tcpdump_package_url="http://download.hosts.prod.psi.bos.redhat.com/brewroot/packages/openvswitch2.17/2.17.0/$build_id.el9fdp/noarch/$tcpdump_package"
	http_code=$(curl --silent --head --write-out '%{http_code}' "$package_url" | grep HTTP | awk '{print $2}')
	if [[ "$http_code" -ne 200 ]]; then echo "$package_url is NOT a valid link.  Exiting..."; exit 1; fi
	http_code=$(curl --silent --head --write-out '%{http_code}' "$python_package_url" | grep HTTP | awk '{print $2}')
	if [[ "$http_code" -ne 200 ]]; then echo "$python_package_url is NOT a valid link.  Exiting..."; exit 1; fi
	http_code=$(curl --silent --head --write-out '%{http_code}' "$tcpdump_package_url" | grep HTTP | awk '{print $2}')
	if [[ "$http_code" -ne 200 ]]; then echo "$tcpdump_package_url is NOT a valid link.  Exiting..."; exit 1; fi
	echo "OVS217_$fdp_release"_RHEL9=${package_url} >> $new_package_list_file
	echo "OVS217_PYTHON_$fdp_release"_RHEL9=${python_package_url} >> $new_package_list_file
	echo "OVS217_TCPDUMP_$fdp_release"_RHEL9=${tcpdump_package_url} >> $new_package_list_file
	echo ""
	echo OVS217_$fdp_release"_RHEL9 package location: $package_url"
	echo OVS217_PYTHON_$fdp_release"_RHEL9 package location: $python_package_url"
	echo OVS217_TCPDUMP_$fdp_release"_RHEL9 package location: $tcpdump_package_url"
	echo ""
fi

errata=$(grep 'OVS-3.00 RHEL-9' $fdp_errata_list_file | awk '{print $3}')
if [[ -z $errata ]]; then
	echo "No errata provided so OVS 3.00 RHEL-9 package will not be added for FDP $fdp_release"
	echo ""
else
	curl -su : --negotiate https://errata.devel.redhat.com/api/v1/erratum/$errata/builds | jq > ~/temp/builds.txt
	build=$(grep -A8 '"x86_64": \[' ~/temp/builds.txt | egrep -v 'scripts|devel|ipsec|debugsource|debuginfo|\[' | head -n1 | awk -F '"' '{print $2}')
	build_id=$(echo $build | awk -F - '{print $NF}' | awk -F ".el9" '{print $1}')
	python_package=$(grep -A8 '"x86_64": \[' ~/temp/builds.txt | egrep -v 'scripts|devel|ipsec|debugsource|debuginfo|\[' | grep -i python | awk -F '"' '{print $2}')
	tcpdump_package=$(grep -A1 '"noarch": \[' ~/temp/builds.txt | tail -n1 | awk -F '"' '{print $2}')
	package_url="http://download.hosts.prod.psi.bos.redhat.com/brewroot/packages/openvswitch3.0/3.0.0/$build_id.el9fdp/x86_64/$build"
	python_package_url="http://download.hosts.prod.psi.bos.redhat.com/brewroot/packages/openvswitch3.0/3.0.0/$build_id.el9fdp/x86_64/$python_package"
	tcpdump_package_url="http://download.hosts.prod.psi.bos.redhat.com/brewroot/packages/openvswitch3.0/3.0.0/$build_id.el9fdp/noarch/$tcpdump_package"
	http_code=$(curl --silent --head --write-out '%{http_code}' "$package_url" | grep HTTP | awk '{print $2}')
	if [[ "$http_code" -ne 200 ]]; then echo "$package_url is NOT a valid link.  Exiting..."; exit 1; fi
	http_code=$(curl --silent --head --write-out '%{http_code}' "$python_package_url" | grep HTTP | awk '{print $2}')
	if [[ "$http_code" -ne 200 ]]; then echo "$python_package_url is NOT a valid link.  Exiting..."; exit 1; fi
	http_code=$(curl --silent --head --write-out '%{http_code}' "$tcpdump_package_url" | grep HTTP | awk '{print $2}')
	if [[ "$http_code" -ne 200 ]]; then echo "$tcpdump_package_url is NOT a valid link.  Exiting..."; exit 1; fi
	echo "OVS300_$fdp_release"_RHEL9=${package_url} >> $new_package_list_file
	echo "OVS300_PYTHON_$fdp_release"_RHEL9=${python_package_url} >> $new_package_list_file
	echo "OVS300_TCPDUMP_$fdp_release"_RHEL9=${tcpdump_package_url} >> $new_package_list_file
	echo ""
	echo OVS300_$fdp_release"_RHEL9 package location: $package_url"
	echo OVS300_PYTHON_$fdp_release"_RHEL9 package location: $python_package_url"
	echo OVS300_TCPDUMP_$fdp_release"_RHEL9 package location: $tcpdump_package_url"
	echo ""
fi

errata=$(grep 'OVS-3.10 RHEL-9' $fdp_errata_list_file | awk '{print $3}')
if [[ -z $errata ]]; then
	echo "No errata provided so OVS 3.10 RHEL-9 package will not be added for FDP $fdp_release"
	echo ""
else
	curl -su : --negotiate https://errata.devel.redhat.com/api/v1/erratum/$errata/builds | jq > ~/temp/builds.txt
	build=$(grep -A8 '"x86_64": \[' ~/temp/builds.txt | egrep -v 'scripts|devel|ipsec|debugsource|debuginfo|\[' | head -n1 | awk -F '"' '{print $2}')
	build_id=$(echo $build | awk -F - '{print $NF}' | awk -F ".el9" '{print $1}')
	python_package=$(grep -A8 '"x86_64": \[' ~/temp/builds.txt | egrep -v 'scripts|devel|ipsec|debugsource|debuginfo|\[' | grep -i python | awk -F '"' '{print $2}')
	tcpdump_package=$(grep -A1 '"noarch": \[' ~/temp/builds.txt | tail -n1 | awk -F '"' '{print $2}')
	package_url="http://download.hosts.prod.psi.bos.redhat.com/brewroot/packages/openvswitch3.1/3.1.0/$build_id.el9fdp/x86_64/$build"
	python_package_url="http://download.hosts.prod.psi.bos.redhat.com/brewroot/packages/openvswitch3.1/3.1.0/$build_id.el9fdp/x86_64/$python_package"
	tcpdump_package_url="http://download.hosts.prod.psi.bos.redhat.com/brewroot/packages/openvswitch3.1/3.1.0/$build_id.el9fdp/noarch/$tcpdump_package"
	http_code=$(curl --silent --head --write-out '%{http_code}' "$package_url" | grep HTTP | awk '{print $2}')
	if [[ "$http_code" -ne 200 ]]; then echo "$package_url is NOT a valid link.  Exiting..."; exit 1; fi
	http_code=$(curl --silent --head --write-out '%{http_code}' "$python_package_url" | grep HTTP | awk '{print $2}')
	if [[ "$http_code" -ne 200 ]]; then echo "$python_package_url is NOT a valid link.  Exiting..."; exit 1; fi
	http_code=$(curl --silent --head --write-out '%{http_code}' "$tcpdump_package_url" | grep HTTP | awk '{print $2}')
	if [[ "$http_code" -ne 200 ]]; then echo "$tcpdump_package_url is NOT a valid link.  Exiting..."; exit 1; fi
	echo "OVS310_$fdp_release"_RHEL9=${package_url} >> $new_package_list_file
	echo "OVS310_PYTHON_$fdp_release"_RHEL9=${python_package_url} >> $new_package_list_file
	echo "OVS310_TCPDUMP_$fdp_release"_RHEL9=${tcpdump_package_url} >> $new_package_list_file
	echo ""
	echo OVS310_$fdp_release"_RHEL9 package location: $package_url"
	echo OVS310_PYTHON_$fdp_release"_RHEL9 package location: $python_package_url"
	echo OVS310_TCPDUMP_$fdp_release"_RHEL9 package location: $tcpdump_package_url"
	echo ""
fi

errata=$(grep 'OVS-3.20 RHEL-9' $fdp_errata_list_file | awk '{print $3}')
if [[ -z $errata ]]; then
	echo "No errata provided so OVS 3.20 RHEL-9 package will not be added for FDP $fdp_release"
	echo ""
else
	curl -su : --negotiate https://errata.devel.redhat.com/api/v1/erratum/$errata/builds | jq > ~/temp/builds.txt
	build=$(grep -A8 '"x86_64": \[' ~/temp/builds.txt | egrep -v 'scripts|devel|ipsec|debugsource|debuginfo|\[' | head -n1 | awk -F '"' '{print $2}')
	build_id=$(echo $build | awk -F - '{print $NF}' | awk -F ".el9" '{print $1}')
	python_package=$(grep -A8 '"x86_64": \[' ~/temp/builds.txt | egrep -v 'scripts|devel|ipsec|debugsource|debuginfo|\[' | grep -i python | awk -F '"' '{print $2}')
	tcpdump_package=$(grep -A1 '"noarch": \[' ~/temp/builds.txt | tail -n1 | awk -F '"' '{print $2}')
	package_url="http://download.hosts.prod.psi.bos.redhat.com/brewroot/packages/openvswitch3.2/3.2.0/$build_id.el9fdp/x86_64/$build"
	python_package_url="http://download.hosts.prod.psi.bos.redhat.com/brewroot/packages/openvswitch3.2/3.2.0/$build_id.el9fdp/x86_64/$python_package"
	tcpdump_package_url="http://download.hosts.prod.psi.bos.redhat.com/brewroot/packages/openvswitch3.2/3.2.0/$build_id.el9fdp/noarch/$tcpdump_package"
	http_code=$(curl --silent --head --write-out '%{http_code}' "$package_url" | grep HTTP | awk '{print $2}')
	if [[ "$http_code" -ne 200 ]]; then echo "$package_url is NOT a valid link.  Exiting..."; exit 1; fi
	http_code=$(curl --silent --head --write-out '%{http_code}' "$python_package_url" | grep HTTP | awk '{print $2}')
	if [[ "$http_code" -ne 200 ]]; then echo "$python_package_url is NOT a valid link.  Exiting..."; exit 1; fi
	http_code=$(curl --silent --head --write-out '%{http_code}' "$tcpdump_package_url" | grep HTTP | awk '{print $2}')
	if [[ "$http_code" -ne 200 ]]; then echo "$tcpdump_package_url is NOT a valid link.  Exiting..."; exit 1; fi
	echo "OVS320_$fdp_release"_RHEL9=${package_url} >> $new_package_list_file
	echo "OVS320_PYTHON_$fdp_release"_RHEL9=${python_package_url} >> $new_package_list_file
	echo "OVS320_TCPDUMP_$fdp_release"_RHEL9=${tcpdump_package_url} >> $new_package_list_file
	echo ""
	echo OVS320_$fdp_release"_RHEL9 package location: $package_url"
	echo OVS320_PYTHON_$fdp_release"_RHEL9 package location: $python_package_url"
	echo OVS320_TCPDUMP_$fdp_release"_RHEL9 package location: $tcpdump_package_url"
	echo ""
fi

errata=$(grep 'OVN-2.13 RHEL-8' $fdp_errata_list_file | awk '{print $3}')
if [[ -z $errata ]]; then
	echo "No errata provided so OVN 2.13 RHEL-8 package will not be added for FDP $fdp_release"
	echo ""
else
	curl -su : --negotiate https://errata.devel.redhat.com/api/v1/erratum/$errata/builds | jq > ~/temp/builds.txt
	ovn_common_build=$(grep -A9 '"x86_64": \[' ~/temp/builds.txt | egrep -v 'vtep|debugsource|debuginfo|\[' | head -n1 | awk -F '"' '{print $2}')
	ovn_central_build=$(grep -A9 '"x86_64": \[' ~/temp/builds.txt | egrep -v 'vtep|debugsource|debuginfo|\[' | tail -n2 | head -n1 | awk -F '"' '{print $2}')
	ovn_host_build=$(grep -A9 '"x86_64": \[' ~/temp/builds.txt | egrep -v 'vtep|debugsource|debuginfo|\[' | tail -n1 | awk -F '"' '{print $2}')
	directory_id=$(echo $ovn_common_build | awk -F "-" '{print $2}')
	build_id=$(echo $ovn_common_build | awk -F "." '{print $4}'  | awk -F "-" '{print $NF}')
	ovn_common_package_url="http://download.hosts.prod.psi.bos.redhat.com/brewroot/packages/ovn2.13/$directory_id/"$build_id".el8fdp/x86_64/$ovn_common_build"
	ovn_central_package_url="http://download.hosts.prod.psi.bos.redhat.com/brewroot/packages/ovn2.13/$directory_id/"$build_id".el8fdp/x86_64/$ovn_central_build"
	ovn_host_package_url="http://download.hosts.prod.psi.bos.redhat.com/brewroot/packages/ovn2.13/$directory_id/"$build_id".el8fdp/x86_64/$ovn_host_build"
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
	echo "OVN_COMMON_213_"$fdp_release"_RHEL8 package location: $ovn_common_package_url"
	echo "OVN_CENTRAL_213_"$fdp_release"_RHEL8 package location: $ovn_central_package_url"
	echo "OVN_HOST_213_"$fdp_release"_RHEL8 package location: $ovn_host_package_url"
	echo ""
fi

errata=$(grep 'OVN-XXXX RHEL-8' $fdp_errata_list_file | awk '{print $3}')
if [[ -z $errata ]]; then
	echo "No errata provided so OVN-XXXX RHEL-8 package will not be added for FDP $fdp_release"
	echo ""
else
	curl -su : --negotiate https://errata.devel.redhat.com/api/v1/erratum/$errata/builds | jq > ~/temp/builds.txt
	ovn_common_build=$(grep -A1 '"x86_64": \[' ~/temp/builds.txt | tail -n1 | awk -F '"' '{print $2}')
	ovn_central_build=$(grep -A2 '"x86_64": \[' ~/temp/builds.txt | tail -n1 | awk -F '"' '{print $2}')
	ovn_host_build=$(grep -A3 '"x86_64": \[' ~/temp/builds.txt | tail -n1 | awk -F '"' '{print $2}')
	year=$(echo $ovn_common_build | awk -F "-" '{print $2}')
	directory_id=$(echo $ovn_common_build | awk -F "-" '{print $3}')
	build_id=$(echo $ovn_common_build | awk -F "." '{print $3}'  | awk -F "-" '{print $NF}')
	ovn_common_package_url="http://download.hosts.prod.psi.bos.redhat.com/brewroot/packages/ovn-$year/$directory_id/"$build_id".el8fdp/x86_64/$ovn_common_build"
	ovn_central_package_url="http://download.hosts.prod.psi.bos.redhat.com/brewroot/packages/ovn-$year/$directory_id/"$build_id".el8fdp/x86_64/$ovn_central_build"
	ovn_host_package_url="http://download.hosts.prod.psi.bos.redhat.com/brewroot/packages/ovn-$year/$directory_id/"$build_id".el8fdp/x86_64/$ovn_host_build"
	http_code=$(curl --silent --head --write-out '%{http_code}' "$ovn_common_package_url" | grep HTTP | awk '{print $2}')
	if [[ "$http_code" -ne 200 ]]; then echo "$ovn_common_package_url is NOT a valid link.  Exiting..."; exit 1; fi
	http_code=$(curl --silent --head --write-out '%{http_code}' "$ovn_central_package_url" | grep HTTP | awk '{print $2}')
	if [[ "$http_code" -ne 200 ]]; then echo "$ovn_central_package_url is NOT a valid link.  Exiting..."; exit 1; fi
	http_code=$(curl --silent --head --write-out '%{http_code}' "$ovn_host_package_url" | grep HTTP | awk '{print $2}')
	if [[ "$http_code" -ne 200 ]]; then echo "$ovn_host_package_url is NOT a valid link.  Exiting..."; exit 1; fi
	echo "OVN_COMMON_"$year"_$fdp_release"_RHEL8=${ovn_common_package_url} >> $new_package_list_file
	echo "OVN_CENTRAL_"$year"_$fdp_release"_RHEL8=${ovn_central_package_url} >> $new_package_list_file
	echo "OVN_HOST_"$year"_$fdp_release"_RHEL8=${ovn_host_package_url} >> $new_package_list_file
	echo ""
	echo ""OVN_COMMON_"$year"_$fdp_release"_RHEL8 package location: $ovn_common_package_url"
	echo ""OVN_CENTRAL_"$year"_$fdp_release"_RHEL8 package location: $ovn_central_package_url"
	echo ""OVN_HOST_"$year"_$fdp_release"_RHEL8 package location: $ovn_host_package_url"
	echo ""
fi

errata=$(grep 'OVN-22.03 RHEL-8' $fdp_errata_list_file | awk '{print $3}')
if [[ -z $errata ]]; then
	echo "No errata provided so OVN-22.03 RHEL-8 package will not be added for FDP $fdp_release"
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
	
	ovn_common_package_url="http://download.hosts.prod.psi.bos.redhat.com/brewroot/packages/ovn$year/$year.$point1/$point2.el8fdp/x86_64/$ovn_common_build"
	ovn_central_package_url="http://download.hosts.prod.psi.bos.redhat.com/brewroot/packages/ovn$year/$year.$point1/$point2.el8fdp/x86_64/$ovn_central_build"
	ovn_host_package_url="http://download.hosts.prod.psi.bos.redhat.com/brewroot/packages/ovn$year/$year.$point1/$point2.el8fdp/x86_64/$ovn_host_build"
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
	echo ""OVN_COMMON_"$revised_year"_$fdp_release"_RHEL8 package location: $ovn_common_package_url"
	echo ""OVN_CENTRAL_"$revised_year"_$fdp_release"_RHEL8 package location: $ovn_central_package_url"
	echo ""OVN_HOST_"$revised_year"_$fdp_release"_RHEL8 package location: $ovn_host_package_url"
	echo ""
fi

errata=$(grep 'OVN-22.03 RHEL-9' $fdp_errata_list_file | awk '{print $3}')
if [[ -z $errata ]]; then
	echo "No errata provided so OVN-22.03 RHEL-9 package will not be added for FDP $fdp_release"
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
	
	ovn_common_package_url="http://download.hosts.prod.psi.bos.redhat.com/brewroot/packages/ovn$year/$year.$point1/$point2.el9fdp/x86_64/$ovn_common_build"
	ovn_central_package_url="http://download.hosts.prod.psi.bos.redhat.com/brewroot/packages/ovn$year/$year.$point1/$point2.el9fdp/x86_64/$ovn_central_build"
	ovn_host_package_url="http://download.hosts.prod.psi.bos.redhat.com/brewroot/packages/ovn$year/$year.$point1/$point2.el9fdp/x86_64/$ovn_host_build"
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
	echo ""OVN_COMMON_"$revised_year"_$fdp_release"_RHEL9 package location: $ovn_common_package_url"
	echo ""OVN_CENTRAL_"$revised_year"_$fdp_release"_RHEL9 package location: $ovn_central_package_url"
	echo ""OVN_HOST_"$revised_year"_$fdp_release"_RHEL9 package location: $ovn_host_package_url"
	echo ""
fi

errata=$(grep 'OVN-22.06 RHEL-8' $fdp_errata_list_file | awk '{print $3}')
if [[ -z $errata ]]; then
	echo "No errata provided so OVN-22.06 RHEL-8 package will not be added for FDP $fdp_release"
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
	
	ovn_common_package_url="http://download.hosts.prod.psi.bos.redhat.com/brewroot/packages/ovn$year/$year.$point1/$point2.el8fdp/x86_64/$ovn_common_build"
	ovn_central_package_url="http://download.hosts.prod.psi.bos.redhat.com/brewroot/packages/ovn$year/$year.$point1/$point2.el8fdp/x86_64/$ovn_central_build"
	ovn_host_package_url="http://download.hosts.prod.psi.bos.redhat.com/brewroot/packages/ovn$year/$year.$point1/$point2.el8fdp/x86_64/$ovn_host_build"
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
	echo ""OVN_COMMON_"$revised_year"_$fdp_release"_RHEL8 package location: $ovn_common_package_url"
	echo ""OVN_CENTRAL_"$revised_year"_$fdp_release"_RHEL8 package location: $ovn_central_package_url"
	echo ""OVN_HOST_"$revised_year"_$fdp_release"_RHEL8 package location: $ovn_host_package_url"
	echo ""
fi

errata=$(grep 'OVN-22.06 RHEL-9' $fdp_errata_list_file | awk '{print $3}')
if [[ -z $errata ]]; then
	echo "No errata provided so OVN-22.06 RHEL-9 package will not be added for FDP $fdp_release"
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
	
	ovn_common_package_url="http://download.hosts.prod.psi.bos.redhat.com/brewroot/packages/ovn$year/$year.$point1/$point2.el9fdp/x86_64/$ovn_common_build"
	ovn_central_package_url="http://download.hosts.prod.psi.bos.redhat.com/brewroot/packages/ovn$year/$year.$point1/$point2.el9fdp/x86_64/$ovn_central_build"
	ovn_host_package_url="http://download.hosts.prod.psi.bos.redhat.com/brewroot/packages/ovn$year/$year.$point1/$point2.el9fdp/x86_64/$ovn_host_build"
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
	echo ""OVN_COMMON_"$revised_year"_$fdp_release"_RHEL9 package location: $ovn_common_package_url"
	echo ""OVN_CENTRAL_"$revised_year"_$fdp_release"_RHEL9 package location: $ovn_central_package_url"
	echo ""OVN_HOST_"$revised_year"_$fdp_release"_RHEL9 package location: $ovn_host_package_url"
	echo ""
fi

errata=$(grep 'OVN-22.09 RHEL-8' $fdp_errata_list_file | awk '{print $3}')
if [[ -z $errata ]]; then
	echo "No errata provided so OVN-22.09 RHEL-8 package will not be added for FDP $fdp_release"
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
	
	ovn_common_package_url="http://download.hosts.prod.psi.bos.redhat.com/brewroot/packages/ovn$year/$year.$point1/$point2.el8fdp/x86_64/$ovn_common_build"
	ovn_central_package_url="http://download.hosts.prod.psi.bos.redhat.com/brewroot/packages/ovn$year/$year.$point1/$point2.el8fdp/x86_64/$ovn_central_build"
	ovn_host_package_url="http://download.hosts.prod.psi.bos.redhat.com/brewroot/packages/ovn$year/$year.$point1/$point2.el8fdp/x86_64/$ovn_host_build"
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
	echo ""OVN_COMMON_"$revised_year"_$fdp_release"_RHEL8 package location: $ovn_common_package_url"
	echo ""OVN_CENTRAL_"$revised_year"_$fdp_release"_RHEL8 package location: $ovn_central_package_url"
	echo ""OVN_HOST_"$revised_year"_$fdp_release"_RHEL8 package location: $ovn_host_package_url"
	echo ""
fi

errata=$(grep 'OVN-22.09 RHEL-9' $fdp_errata_list_file | awk '{print $3}')
if [[ -z $errata ]]; then
	echo "No errata provided so OVN-22.09 RHEL-9 package will not be added for FDP $fdp_release"
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
	
	ovn_common_package_url="http://download.hosts.prod.psi.bos.redhat.com/brewroot/packages/ovn$year/$year.$point1/$point2.el9fdp/x86_64/$ovn_common_build"
	ovn_central_package_url="http://download.hosts.prod.psi.bos.redhat.com/brewroot/packages/ovn$year/$year.$point1/$point2.el9fdp/x86_64/$ovn_central_build"
	ovn_host_package_url="http://download.hosts.prod.psi.bos.redhat.com/brewroot/packages/ovn$year/$year.$point1/$point2.el9fdp/x86_64/$ovn_host_build"
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
	echo ""OVN_COMMON_"$revised_year"_$fdp_release"_RHEL9 package location: $ovn_common_package_url"
	echo ""OVN_CENTRAL_"$revised_year"_$fdp_release"_RHEL9 package location: $ovn_central_package_url"
	echo ""OVN_HOST_"$revised_year"_$fdp_release"_RHEL9 package location: $ovn_host_package_url"
	echo ""
fi

errata=$(grep 'OVN-22.12 RHEL-8' $fdp_errata_list_file | awk '{print $3}')
if [[ -z $errata ]]; then
	echo "No errata provided so OVN-22.12 RHEL-8 package will not be added for FDP $fdp_release"
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
	
	ovn_common_package_url="http://download.hosts.prod.psi.bos.redhat.com/brewroot/packages/ovn$year/$year.$point1/$point2.el8fdp/x86_64/$ovn_common_build"
	ovn_central_package_url="http://download.hosts.prod.psi.bos.redhat.com/brewroot/packages/ovn$year/$year.$point1/$point2.el8fdp/x86_64/$ovn_central_build"
	ovn_host_package_url="http://download.hosts.prod.psi.bos.redhat.com/brewroot/packages/ovn$year/$year.$point1/$point2.el8fdp/x86_64/$ovn_host_build"
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
	echo ""OVN_COMMON_"$revised_year"_$fdp_release"_RHEL8 package location: $ovn_common_package_url"
	echo ""OVN_CENTRAL_"$revised_year"_$fdp_release"_RHEL8 package location: $ovn_central_package_url"
	echo ""OVN_HOST_"$revised_year"_$fdp_release"_RHEL8 package location: $ovn_host_package_url"
	echo ""
fi

errata=$(grep 'OVN-22.12 RHEL-9' $fdp_errata_list_file | awk '{print $3}')
if [[ -z $errata ]]; then
	echo "No errata provided so OVN-22.12 RHEL-9 package will not be added for FDP $fdp_release"
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
	
	ovn_common_package_url="http://download.hosts.prod.psi.bos.redhat.com/brewroot/packages/ovn$year/$year.$point1/$point2.el9fdp/x86_64/$ovn_common_build"
	ovn_central_package_url="http://download.hosts.prod.psi.bos.redhat.com/brewroot/packages/ovn$year/$year.$point1/$point2.el9fdp/x86_64/$ovn_central_build"
	ovn_host_package_url="http://download.hosts.prod.psi.bos.redhat.com/brewroot/packages/ovn$year/$year.$point1/$point2.el9fdp/x86_64/$ovn_host_build"
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
	echo ""OVN_COMMON_"$revised_year"_$fdp_release"_RHEL9 package location: $ovn_common_package_url"
	echo ""OVN_CENTRAL_"$revised_year"_$fdp_release"_RHEL9 package location: $ovn_central_package_url"
	echo ""OVN_HOST_"$revised_year"_$fdp_release"_RHEL9 package location: $ovn_host_package_url"
	echo ""
fi

errata=$(grep 'OVN-23.03 RHEL-8' $fdp_errata_list_file | awk '{print $3}')
if [[ -z $errata ]]; then
	echo "No errata provided so OVN-23.03 RHEL-8 package will not be added for FDP $fdp_release"
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
	
	ovn_common_package_url="http://download.hosts.prod.psi.bos.redhat.com/brewroot/packages/ovn$year/$year.$point1/$point2.el8fdp/x86_64/$ovn_common_build"
	ovn_central_package_url="http://download.hosts.prod.psi.bos.redhat.com/brewroot/packages/ovn$year/$year.$point1/$point2.el8fdp/x86_64/$ovn_central_build"
	ovn_host_package_url="http://download.hosts.prod.psi.bos.redhat.com/brewroot/packages/ovn$year/$year.$point1/$point2.el8fdp/x86_64/$ovn_host_build"
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
	echo ""OVN_COMMON_"$revised_year"_$fdp_release"_RHEL8 package location: $ovn_common_package_url"
	echo ""OVN_CENTRAL_"$revised_year"_$fdp_release"_RHEL8 package location: $ovn_central_package_url"
	echo ""OVN_HOST_"$revised_year"_$fdp_release"_RHEL8 package location: $ovn_host_package_url"
	echo ""
fi

errata=$(grep 'OVN-23.06 RHEL-8' $fdp_errata_list_file | awk '{print $3}')
if [[ -z $errata ]]; then
	echo "No errata provided so OVN-23.06 RHEL-8 package will not be added for FDP $fdp_release"
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
	
	ovn_common_package_url="http://download.hosts.prod.psi.bos.redhat.com/brewroot/packages/ovn$year/$year.$point1/$point2.el8fdp/x86_64/$ovn_common_build"
	ovn_central_package_url="http://download.hosts.prod.psi.bos.redhat.com/brewroot/packages/ovn$year/$year.$point1/$point2.el8fdp/x86_64/$ovn_central_build"
	ovn_host_package_url="http://download.hosts.prod.psi.bos.redhat.com/brewroot/packages/ovn$year/$year.$point1/$point2.el8fdp/x86_64/$ovn_host_build"
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
	echo ""OVN_COMMON_"$revised_year"_$fdp_release"_RHEL8 package location: $ovn_common_package_url"
	echo ""OVN_CENTRAL_"$revised_year"_$fdp_release"_RHEL8 package location: $ovn_central_package_url"
	echo ""OVN_HOST_"$revised_year"_$fdp_release"_RHEL8 package location: $ovn_host_package_url"
	echo ""
fi

errata=$(grep 'OVN-23.03 RHEL-9' $fdp_errata_list_file | awk '{print $3}')
if [[ -z $errata ]]; then
	echo "No errata provided so OVN-23.03 RHEL-9 package will not be added for FDP $fdp_release"
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
	
	ovn_common_package_url="http://download.hosts.prod.psi.bos.redhat.com/brewroot/packages/ovn$year/$year.$point1/$point2.el9fdp/x86_64/$ovn_common_build"
	ovn_central_package_url="http://download.hosts.prod.psi.bos.redhat.com/brewroot/packages/ovn$year/$year.$point1/$point2.el9fdp/x86_64/$ovn_central_build"
	ovn_host_package_url="http://download.hosts.prod.psi.bos.redhat.com/brewroot/packages/ovn$year/$year.$point1/$point2.el9fdp/x86_64/$ovn_host_build"
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
	echo ""OVN_COMMON_"$revised_year"_$fdp_release"_RHEL9 package location: $ovn_common_package_url"
	echo ""OVN_CENTRAL_"$revised_year"_$fdp_release"_RHEL9 package location: $ovn_central_package_url"
	echo ""OVN_HOST_"$revised_year"_$fdp_release"_RHEL9 package location: $ovn_host_package_url"
	echo ""
fi

errata=$(grep 'OVN-23.06 RHEL-9' $fdp_errata_list_file | awk '{print $3}')
if [[ -z $errata ]]; then
	echo "No errata provided so OVN-23.06 RHEL-9 package will not be added for FDP $fdp_release"
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
	
	ovn_common_package_url="http://download.hosts.prod.psi.bos.redhat.com/brewroot/packages/ovn$year/$year.$point1/$point2.el9fdp/x86_64/$ovn_common_build"
	ovn_central_package_url="http://download.hosts.prod.psi.bos.redhat.com/brewroot/packages/ovn$year/$year.$point1/$point2.el9fdp/x86_64/$ovn_central_build"
	ovn_host_package_url="http://download.hosts.prod.psi.bos.redhat.com/brewroot/packages/ovn$year/$year.$point1/$point2.el9fdp/x86_64/$ovn_host_build"
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
	echo ""OVN_COMMON_"$revised_year"_$fdp_release"_RHEL9 package location: $ovn_common_package_url"
	echo ""OVN_CENTRAL_"$revised_year"_$fdp_release"_RHEL9 package location: $ovn_central_package_url"
	echo ""OVN_HOST_"$revised_year"_$fdp_release"_RHEL9 package location: $ovn_host_package_url"
	echo ""
fi

errata=$(grep 'OVN-23.09 RHEL-9' $fdp_errata_list_file | awk '{print $3}')
if [[ -z $errata ]]; then
	echo "No errata provided so OVN-23.09 RHEL-9 package will not be added for FDP $fdp_release"
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
	
	ovn_common_package_url="http://download.hosts.prod.psi.bos.redhat.com/brewroot/packages/ovn$year/$year.$point1/$point2.el9fdp/x86_64/$ovn_common_build"
	ovn_central_package_url="http://download.hosts.prod.psi.bos.redhat.com/brewroot/packages/ovn$year/$year.$point1/$point2.el9fdp/x86_64/$ovn_central_build"
	ovn_host_package_url="http://download.hosts.prod.psi.bos.redhat.com/brewroot/packages/ovn$year/$year.$point1/$point2.el9fdp/x86_64/$ovn_host_build"
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
	echo ""OVN_COMMON_"$revised_year"_$fdp_release"_RHEL9 package location: $ovn_common_package_url"
	echo ""OVN_CENTRAL_"$revised_year"_$fdp_release"_RHEL9 package location: $ovn_central_package_url"
	echo ""OVN_HOST_"$revised_year"_$fdp_release"_RHEL9 package location: $ovn_host_package_url"
	echo ""
fi

cat $new_package_list_file >> /home/ralongi/git/my_fork/kernel/networking/openvswitch/common/package_list.sh



