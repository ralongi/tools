#!/bin/bash

# To be run on laptop system (assumes kernel tests repo is installed locally under ~/git/)
# Usage: nohup link_check.sh &

dbg_flag=${dbg_flag:-"set +x"}
$dbg_flag
iface1=${iface1:-"ens1f0"}
iface2=${iface2:-"ens1f1"}
sleep_time=${sleep_time:-30m}

. ~/git/kernel/networking/openvswitch/common/install.sh

target=${target:-"wsfd-advnetlab34.anl.lab.eng.bos.redhat.com"}

ping -c1 $target
if [[ $? -ne 0 ]]; then
	notify-send -u critical -t 0 Test "$target appears to be DOWN"
	exit
fi

# Install EPEL repo and sshpass package
pvt_epel_install
pvt_sshpass_install
wget -O ~/temp/junk.txt http://netqe-infra01.knqe.eng.rdu2.dc.redhat.com/packages/junk.txt
sleep 3
sshpass -f ~/temp/junk.txt ssh-copy-id -o "StrictHostKeyChecking no" -i ~/.ssh/id_rsa.pub root@$target
wait
sleep 3
ssh -q root@$target exit
if [[ $? -ne 0 ]]; then 
    sshpass -f ~/temp/junk.txt ssh-copy-id -o "StrictHostKeyChecking no" -i ~/.ssh/id_rsa.pub root@$target
    wait
    sleep 3
fi

ssh -q root@$target exit
if [[ $? -ne 0 ]]; then
	echo "Couldn't copy ssh key to $target.  Exiting test..."
	exit
fi

while [ 1 ]; do
	sleep $sleep_time
	ping -c1 $target
	if [[ $? -ne 0 ]]; then
		notify-send -u critical -t 0 Test "$target appears to be DOWN"
		break
	fi
	ssh -o "StrictHostKeyChecking no" root@$target ip link show $iface1 | grep 'NO-CARRIER'
	if [[ $? -eq 0 ]]; then
		notify-send -u critical -t 0 Test "Interface $iface1 is DOWN on $target"
		break
	fi
	ssh -o "StrictHostKeyChecking no" root@$target ip link show $iface2 | grep 'NO-CARRIER'
	if [[ $? -eq 0 ]]; then
		notify-send -u critical -t 0 Test "Interface $iface2 is DOWN on $target"
		break
	fi
done
exit 0
