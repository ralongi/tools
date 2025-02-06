#!/bin/bash
$dbg_flag
# Script to get info on interfaces on target host

if [[ ! $(which lspci) ]]; then yum -y install pciutils; fi
rm -f ~/nic_info.txt
mgmt_iface=$(ip route | awk '/default/{match($0,"dev ([^ ]+)",M); print M[1]; exit}')
compose_id=$(grep 'server=' /root/anaconda-ks.cfg | grep nfs | awk -F "/" '{print $(NF-5)}')
echo "" >> ~/nic_info.txt
echo "NIC and Interface list for $(hostname):" >> ~/nic_info.txt
echo -e "Note that only physical interfaces are listed\n" >> ~/nic_info.txt
echo -e "The management interface for $(hostname) is: $mgmt_iface\n" >> ~/nic_info.txt
echo -e "Compose ID on $(hostname) is: $compose_id\n" >> ~/nic_info.txt
echo -e "Running kernel version is: $(uname -r)\n" >> ~/nic_info.txt
echo "---------------------------------------------------------------------" >> ~/nic_info.txt

for i in $(ls /sys/class/net | grep -E -v "lo|ovs|vir|vnet|tun|$mgmt_iface"); do
	driver=$(ethtool -i $i | grep driver | awk '{print $2}')
	driver_version=$(ethtool -i $i | grep version | grep -E -v 'firmware|expansion' | awk '{print $2}')
	firmware_version=$(ethtool -i $i | grep 'firmware-version' | awk '{print $2}')
	pci_address=$(ethtool -i $i | grep bus | awk '{print $NF}')
	pci_address_short=$(ethtool -i $i | grep bus | awk -F ":" '{print $3":"$4}')
	nic_name=$(lspci -v | grep $pci_address_short | awk -F ":" '{print $NF}')
	speed=$(ethtool $i | grep Speed | awk '{print $2}' | tr -d '[a-z A-Z /]')
	available_speeds=$(ethtool $i | awk '/Supported link modes/,/Supported pause frame use/' | grep -v pause | awk '{print $NF}' | awk -F 'base' '{print $1}' | sort -n | uniq)
	mac_address=$(ip -d link show $i | grep 'link/ether' | awk '{print $2}')
	existing_physical_slot=$(grep -A3 ${i:0:5} ~/nic_info.txt | head -n12 | grep 'Slot location' | awk '{print $NF}')
	part_number=$(lspci -vvnn -s $pci_address_short | grep Part | awk '{print $NF}')
	pciid=$(lspci -nn -s $pci_address_short | awk -F '[' '{print $3}' | awk -F ']' '{print $1}')
	pci_lanes=$(dmidecode | grep -B10 ${pci_address%?} | grep Type | awk '{print $2}')
	
	if [[ $(echo $i | grep ${mgmt_iface%?}) ]]; then
		physical_slot="Onboard"
	elif [[ $existing_physical_slot ]]; then
		physical_slot=$existing_physical_slot
	else
		physical_slot=$(dmidecode -t slot | grep -B8 $pci_address_short | grep ID | awk '{print $NF}')
	fi
	
	if [[ $physical_slot == "Onboard" ]]; then pci_lanes=NA; fi
	if [[ $(echo $speed | grep '!') ]]; then speed="Unknown"; fi
	link_detected=$(ethtool $i | grep 'Link detected' | awk '{print $3}')
	echo -e "Interface: $i\n" >> ~/nic_info.txt
	echo "    Driver ($i): $driver" >> ~/nic_info.txt
	echo "    Driver version ($i): $driver_version" >> ~/nic_info.txt
	echo "    Firmware version ($i): $firmware_version" >> ~/nic_info.txt
	echo "    Card ($i): $nic_name (Part #: $part_number, PCIID: $pciid)" >> ~/nic_info.txt
	echo "    PCI Bus Address ($i): $pci_address" >> ~/nic_info.txt
	echo "    Speed ($i): $speed Mbps" >> ~/nic_info.txt
	echo "    Available speeds ($i): $(echo $available_speeds) Mbps" >> ~/nic_info.txt
	echo "    Link detected ($i): $link_detected" >> ~/nic_info.txt
	echo "    MAC Address ($i): $mac_address" >> ~/nic_info.txt
	echo "    Slot location ($i): $physical_slot" >> ~/nic_info.txt
	echo "    PCI Lanes ($i): $pci_lanes" >> ~/nic_info.txt
	echo "---------------------------------------------------------------------" >> ~/nic_info.txt
done

more ~/nic_info.txt
