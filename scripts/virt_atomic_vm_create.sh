#!/bin/bash

## script to create a RHEL Atomic VM

## 

vm=atomic-vm
iso=installer.iso
##########################################################

# - tidy up any prior installation of this VM

virsh destroy $vm
virsh undefine $vm
virsh vol-delete --pool default /var/lib/libvirt/images/$vm.qcow2
virsh pool-refresh default
#############################################################
virt-install --name $vm --ram 2048 --vcpus 2 --disk path=/var/lib/libvirt/images/$vm.qcow2,format=qcow2,bus=virtio,cache=none,size=8 --cdrom /var/lib/libvirt/boot/$iso --network=bridge:virbr0,model=virtio --noreboot

exit
