#! /bin/bash

# Script to check status of erratas listed in ~/github/tools/scripts/fdp_errata_list.txt so be sure to update that file with the correct errata info before running script

$dbg_flag
alias rm='rm'
rm -f ~/temp/errata_status_info.tmp
pushd ~/temp

if [[ -z $errata_list ]]; then
	errata_list=$(egrep -i 'ovs|ovn|misc' ~/github/tools/scripts/fdp_errata_list.txt | grep -vi tests | awk '{print $3}')
fi
total_erratas=$(echo $errata_list | wc -w)
echo "Gathering status info for $total_erratas erratas.  This may take a minute or two..."
echo ""
for i in $errata_list; do
	errata=$i
	rm -f ~/temp/$errata"_bz_info.tmp"
	curl -su : --negotiate https://errata.devel.redhat.com/api/v1/erratum/$errata/builds | jq > ~/temp/builds.txt
	build=$(grep -A2 '"builds":' ~/temp/builds.txt | tail -n1 | awk -F '"' '{print $2}')
	errata_url="https://errata.devel.redhat.com/advisory/$errata"
	errata_status=$(curl -su : --negotiate https://errata.devel.redhat.com/api/v1/erratum/$i | jq | grep -i '"status":' | head -n1 | awk '{print $NF}' | tr -d '",')
	rm -f ~/temp/errata_flags.tmp
	errata-tool advisory get $i | grep Flags | awk -F 'Flags:' '{print $2}' > ~/temp/errata_flags.tmp
	sed -i 's/tps_wait/TPS Tests,/g' ~/temp/errata_flags.tmp
	sed -i 's/tps_errors/TPS Errors,/g' ~/temp/errata_flags.tmp
	sed -i 's/needs_distqa/RHNQA TPS Tests,/g' ~/temp/errata_flags.tmp
	sed -i 's/needs_security/Product Security Approval,/g' ~/temp/errata_flags.tmp
	sed -i 's/needs_docs/Docs Approval,/g' ~/temp/errata_flags.tmp
	errata_flags=$(cat ~/temp/errata_flags.tmp | sed 's/.$//')
	echo "Errata flags: $errata_flags"
	curl -su : --negotiate https://errata.devel.redhat.com/api/v1/erratum/$errata | jq | grep -A3 '"bug": {' | grep -iw '"id":' > ~/temp/$errata_"bz_list.tmp"
	sed -i 's/[^0-9]*//g' ~/temp/$errata_"bz_list.tmp"
	echo "" >> ~/temp/$errata"_bz_info.tmp"
	echo "BZ List for Errata $i:" >> ~/temp/$errata"_bz_info.tmp"
	echo "" >> ~/temp/$errata"_bz_info.tmp"
	for i in $(cat ~/temp/$errata_"bz_list.tmp"); do
		bz_status=$(curl -su : --negotiate https://errata.devel.redhat.com/api/v1/erratum/$errata | jq | grep -B2 short_desc | grep -A1 $i | tail -n1 | awk '{print $NF}' | tr -d '",')
		bz_description=$(curl -su : --negotiate https://errata.devel.redhat.com/api/v1/erratum/$errata | jq | grep -A3 $i | grep short_desc | awk -F ':' '{print $NF}' | awk -F '"' '{print $2}')
		bz_url="https://bugzilla.redhat.com/show_bug.cgi?id=$i"
		echo "BZ URL: $bz_url" >> ~/temp/$errata"_bz_info.tmp"
		echo "BZ Description: $bz_description" >> ~/temp/$errata"_bz_info.tmp"
		echo "BZ Status: $bz_status" >> ~/temp/$errata"_bz_info.tmp"
		echo "" >> ~/temp/$errata"_bz_info.tmp"
	done
	echo "###################################################################################" >>  ~/temp/errata_status_info.tmp
	echo "" >>  ~/temp/errata_status_info.tmp
	errata_flags=$(echo $errata_flags | tr -d "")
	echo "Errata URL: $errata_url" >>  ~/temp/errata_status_info.tmp
	echo "Errata Status: $errata_status" >>  ~/temp/errata_status_info.tmp
	echo "Package: $build" >>  ~/temp/errata_status_info.tmp
	echo "Outstanding Items: $errata_flags" >>  ~/temp/errata_status_info.tmp
	cat ~/temp/$errata"_bz_info.tmp" >> ~/temp/errata_status_info.tmp
done

echo ""
echo ""
echo ""
echo ""
cat ~/temp/errata_status_info.tmp
rm -f ~/temp/errata_status_info.tmp
rm -f ~/temp/*bz_info.tmp
alias 'rm=rm-i'
popd
