#!/bin/bash

# script to create installer file for a given utility/tool

tool_path=$1

if [[ $# -lt 1 ]]; then
	echo "Please provide the full path to the target tool directory"
	echo "Usage: $0 <tool directory name>"
	echo "Example: $0 ~/tools/my_utility_dir"
	exit 0
fi

tool_name=$(echo $tool_path | awk -F "/" '{print $NF}')

sedeasy ()
{
sed -i "s/$(echo $1 | sed -e 's/\([[\/.*]\|\]\)/\\&/g')/$(echo $2 | sed -e 's/[\/&]/\\&/g')/g" $3
}

if [[ ! -d ~/installers/$tool_name ]]; then mkdir ~/installers/$tool_name/; fi
/bin/cp -f $tool_path/* ~/installers/$tool_name/
pushd ~/installers/ > /dev/null
tar cJf ./$tool_name/$tool_name.tar.xz ./$tool_name 2> /dev/null
/bin/cp -f ~/installers/master_installer.sh ~/installers/$tool_name/install.sh
sedeasy "tool_name_temp" "$tool_name" ~/installers/$tool_name/install.sh
cat ~/installers/$tool_name/$tool_name.tar.xz >> ~/installers/$tool_name/install.sh
chmod +x ~/installers/$tool_name/install.sh
mv -f ~/installers/$tool_name/install.sh ~/installers/$tool_name/install
pushd ~/installers/$tool_name/
file_list=$(ls | egrep -iv 'install|README')
for i in $file_list; do rm -f $i; done
popd > /dev/null
popd > /dev/null

echo ""
echo "Installer (install) and README files for $tool_name are here: ~/installers/$tool_name/"

