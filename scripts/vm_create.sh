#!/bin/bash

# make sure openvswitch and virtualization packages are installed

ovsbr="myovs"

openvswitch_rpm="http://download.eng.bos.redhat.com/brewroot/packages/openvswitch/2.4.0/1.el7/x86_64/openvswitch-2.4.0-1.el7.x86_64.rpm"
rpm -ivh $openvswitch_rpm
systemctl start openvswitch.service && systemctl enable openvswitch.service

virt_install()
{
	echo "Installing Virtualization packages..."
	local rhel_version=$(cut -f1 -d. /etc/redhat-release | sed 's/[^0-9]//g')
	if (($rhel_version == 6)); then
		yum -y groupinstall virtualization virtualization-platform virtualization-client virtualization-tools x11 fonts
		yum -y install virt-manager virt-viewer virt-install libvirt || true
		chkconfig libvirtd on; service libvirtd start
	elif (($rhel_version == 7)); then
		yum -y groupinstall virtualization-host-environment virtualization-tools virtualization virtualization-client virtualization-platform x11 fonts
		yum -y install virt-manager virt-viewer virt-install libvirt || true
		systemctl enable libvirtd.service; systemctl start libvirtd.service
	fi
}

virt_install

# create OVS bridge required by VM (bridge name must match the bridge name in the VM XML file)
ovs-vsctl --if-exists del-br $ovsbr
ovs-vsctl add-br $ovsbr

# method 1 to create a VM
# pull down existing qcow2 VM image file and VM XML config file from server and start the VM (assumes you already have these files available with settings as referenced below).

vm_image_name="rhel7.2.qcow2"
vm_image_location="http://netqe-infra01.knqe.lab.eng.bos.redhat.com"
vm_xml_file="vm_rhel72.xml"
vm="g1"

# function to pull down the necessary VMfiles
vm_file_download()
{
    # pull down vm image and xml files to be used to create VM
    rm -f /tmp/$vm_xml_file /var/lib/libvirt/images/$vm_image_name
    wget -nv -O /var/lib/libvirt/images/$vm_image_name $vm_image_location/$vm_image_name 
    wget -nv -O /tmp/$vm.xml $vm_image_location/$vm_xml_file
}

vm_file_download

# define VM using XML file, start VM
virsh define /tmp/$vm.xml
virsh start $vm
sleep 30

# you can now connect to the VM console via "virsh console $vm"
