#!/bin/bash

# Script to get info on interfaces on target host

rm -f /home/nic_info.txt
echo "" >> /home/nic_info.txt
echo "NIC and Interface list for $(hostname):" >> /home/nic_info.txt
echo -e "Note that only physical interfaces are listed\n" >> /home/nic_info.txt
echo "---------------------------------------------------------------------" >> /home/nic_info.txt

for i in $(ls /sys/class/net | egrep -v 'lo|ovs|vir|vnet|tun'); do
	driver=$(ethtool -i $i | grep driver | awk '{print $NF}')
	pci_slot=$(ethtool -i $i | grep bus | awk -F ":" '{print $3":"$4$5}')
	nic_name=$(lspci -v | grep $pci_slot | awk -F ":" '{print $NF}')
	echo -e "Interface: $i\n" >> /home/nic_info.txt
	echo "    Driver: $driver" >> /home/nic_info.txt
	echo "    Card: $nic_name" >> /home/nic_info.txt
	echo "    PCI Slot: $pci_slot" >> /home/nic_info.txt
	echo "---------------------------------------------------------------------" >> /home/nic_info.txt
done

more /home/nic_info.txt

