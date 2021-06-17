#!/bin/bash

# Tool to obtain latest available beaker compose for a given RHEL minor release
#set -x

target_rhel_version=$1
if [[ "$target_rhel_version" == "8.0" ]]; then
	target_rhel_version="8.0.0"
fi
search_string="\-$target_rhel_version\-"

display_usage()
{
	echo "This script will report the latest updates compose available for the RHEL version provided"
	echo "Usage: $0 <target_RHEL-version>"
	echo "Example: $0 RHEL-7.5"
	exit 0
}

if [[ $# -lt 1 ]] || [[ $1 = "-h" ]] || [[ $1 = "--help" ]]	|| [[ $1 = "-?" ]]; then
	display_usage
fi

pushd ~ > /dev/null

rm -f index.html*

wget -q --execute="robots = off" --convert-links --no-parent --wait=1 https://beaker.engineering.redhat.com/distros/?simplesearch="$target_rhel_version"

if [[ $(grep "$search_string"updates index.html?simplesearch="$target_rhel_version") ]]; then
	updates_compose_id=$(grep "$search_string"updates index.html?simplesearch="$target_rhel_version" | grep -v "\.n\." | head -n1 | awk -F ">" '{print $2}' | awk -F "<" '{print $1}')
elif [[ $(grep "$search_string" index.html?simplesearch="$target_rhel_version") ]]; then
	updates_compose_id=$(grep "$search_string" index.html?simplesearch="$target_rhel_version" | grep -v "\.n\." | head -n1 | awk -F ">" '{print $2}' | awk -F "<" '{print $1}')
else
	updates_compose_id="$target_rhel_version"
fi

echo ""
echo "The latest beaker compose ID available for $target_rhel_version is: $updates_compose_id"
echo ""

rm -f index.html* 

popd > /dev/null
	
