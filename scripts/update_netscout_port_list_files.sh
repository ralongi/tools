#!/bin/bash

$dbg_flag

file1=~/git/kernel/networking/openvswitch/common/bos_3200_ports.txt
file2=~/temp/bos_3200_ports.txt
file3=~/git/kernel/networking/openvswitch/common/bos_3903_ports.txt
file4=~/temp/bos_3903_ports.txt

. ~/.bashrc
ns_show_ports bos_3200 > $file2
sed -i '1,5d' $file2

ns_show_ports bos_3903 > $file4
sed -i '1,5d' $file4

if [[ $(diff $file1 $file2) ]]; then
	/bin/cp -f $file2 $file1
	pushd /home/ralongi/git/kernel/networking/
	git add openvswitch/common/bos_3200_ports.txt
	git commit -o openvswitch/common/bos_3200_ports.txt -m "Updated Netscout port list."
	git pull --rebase && git push
	/home/ralongi/github/tools/scripts/bkrtag.sh openvswitch/common/
	popd
fi

if [[ $(diff $file3 $file4) ]]; then
	/bin/cp -f $file4 $file3
	pushd /home/ralongi/git/kernel/networking/
	git add openvswitch/common/bos_3903_ports.txt
	git commit -o openvswitch/common/bos_3903_ports.txt -m "Updated Netscout port list."
	git pull --rebase && git push
	/home/ralongi/github/tools/scripts/bkrtag.sh openvswitch/common/
	popd
fi
