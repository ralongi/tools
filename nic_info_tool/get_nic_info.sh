#!/bin/bash

# Script to get info on interfaces on target host

if [[ ! $(which lspci) ]]; then yum -y install pciutils; fi
rm -f ~/nic_info.txt
mgmt_iface=$(ip route | awk '/default/{match($0,"dev ([^ ]+)",M); print M[1]; exit}')
echo "" >> ~/nic_info.txt
echo "NIC and Interface list for $(hostname):" >> ~/nic_info.txt
echo -e "Note that only physical interfaces are listed\n" >> ~/nic_info.txt
echo -e "The management interface for $(hostname) is: $mgmt_iface\n" >> ~/nic_info.txt
echo "---------------------------------------------------------------------" >> ~/nic_info.txt

for i in $(ls /sys/class/net | egrep -v "lo|ovs|vir|vnet|tun|$mgmt_iface"); do
	driver=$(ethtool -i $i | grep driver | awk '{print $2}')
	driver_version=$(ethtool -i $i | grep version | egrep -v 'firmware|expansion' | awk '{print $2}')
	firmware_version=$(ethtool -i $i | grep 'firmware-version' | awk '{print $2}')
	pci_slot=$(ethtool -i $i | grep bus | awk '{print $NF}')
	pci_slot_short=$(ethtool -i $i | grep bus | awk -F ":" '{print $3":"$4$5}')
	nic_name=$(lspci -v | grep $pci_slot_short | awk -F ":" '{print $NF}')
	speed=$(ethtool $i | grep Speed | awk '{print $2}' | tr -d '[a-z A-Z /]')
	if [[ $(echo $speed | grep '!') ]]; then speed="Unknown"; fi
	link_detected=$(ethtool $i | grep 'Link detected' | awk '{print $NF}')
	echo -e "Interface: $i\n" >> ~/nic_info.txt
	echo "    Driver: $driver" >> ~/nic_info.txt
	echo "    Driver version: $driver_version" >> ~/nic_info.txt
	echo "    Firmware version: $firmware_version" >> ~/nic_info.txt
	echo "    Card: $nic_name" >> ~/nic_info.txt
	echo "    PCI Slot: $pci_slot" >> ~/nic_info.txt
	echo "    Speed: $speed Mbps" >> ~/nic_info.txt
	echo "    Link detected: $link_detected" >> ~/nic_info.txt
	echo "---------------------------------------------------------------------" >> ~/nic_info.txt
done

more ~/nic_info.txt
