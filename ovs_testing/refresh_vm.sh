vm_name="g1"

virsh destroy $vm_name
virsh undefine $vm_name
rm -f /var/lib/libvirt/images/g1.qcow2 
cp /var/lib/libvirt/images/master.qcow2 /var/lib/libvirt/images/g1.qcow2
virsh define /home/g1.xml 
virsh start g1

