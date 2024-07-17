#!/bin/bash

# Variables
RPM_OVS="http://download.eng.bos.redhat.com/brewroot/vol/rhel-9/packages/openvswitch3.3/3.3.0/13.el9fdp/x86_64/openvswitch3.3-3.3.0-13.el9fdp.x86_64.rpm"
RPM_OVS_SELINUX="http://download.eng.bos.redhat.com/brewroot/vol/rhel-9/packages/openvswitch-selinux-extra-policy/1.0/34.el9fdp/noarch/openvswitch-selinux-extra-policy-1.0-34.el9fdp.noarch.rpm"
VM1_NAME="g1"
VM2_NAME="g2"
# VM_IMAGE="/var/lib/libvirt/images/Fedora40.qcow2" # Path to the VM image
VM_IMAGE="/var/lib/libvirt/images/rhel-9.5.qcow2" # Path to the VM image
VM_MEMORY="4096" # Memory in MB
VM_VCPUS="2" # Number of vCPUs
BRIDGE_NAME="ovs-br0"
NETWORK_NAME="vm-net"
OVS_INTERNAL_PORT="ovs-port0"
OSINFO="fedora39"

# Install necessary packages
# dnf update -y
dnf install -y wget qemu-kvm libvirt-daemon libvirt-client virt-install libguestfs-tools-c kernel-tools $RPM_OVS $RPM_OVS_SELINUX

# Enable and start libvirtd and openvswitch services
systemctl enable libvirtd
usermod -a -G libvirt $(whoami)
systemctl restart libvirtd
systemctl enable openvswitch
systemctl start openvswitch

# Download vm image
# wget -O $VM_IMAGE https://download.fedoraproject.org/pub/fedora/linux/releases/40/Cloud/x86_64/images/Fedora-Cloud-Base-Generic.x86_64-40-1.14.qcow2
wget -O $VM_IMAGE http://netqe-infra01.knqe.eng.rdu2.dc.redhat.com/share/vms/OVS/rhel9.5.qcow2
export LIBVIRT_DEFAULT_URI="qemu:///system"

# Create the virtual bridge using OVS
ovs-vsctl add-br $BRIDGE_NAME

# Define a new virtual network
cat <<EOF | tee /etc/libvirt/qemu/networks/$NETWORK_NAME.xml
<network>
  <name>$NETWORK_NAME</name>
  <forward mode='bridge'/>
  <bridge name='$BRIDGE_NAME'/>
  <virtualport type='openvswitch'/>
</network>
EOF

# Start the new network
virsh net-define /etc/libvirt/qemu/networks/$NETWORK_NAME.xml
virsh net-start $NETWORK_NAME
virsh net-autostart $NETWORK_NAME

# Function to create VM
create_vm() {
    local VM_NAME=$1
    /bin/cp -f $VM_IMAGE /var/lib/libvirt/images/$VM_NAME.qcow2
    
    virt-sysprep \
        --root-password password:redhat \
        --uninstall cloud-init \
        --selinux-relabel -a /var/lib/libvirt/images/$VM_NAME.qcow2
    virt-install \
        --name $VM_NAME \
        --ram $VM_MEMORY \
        --vcpus $VM_VCPUS \
        --disk path=/var/lib/libvirt/images/$VM_NAME.qcow2 \
        --network network=$NETWORK_NAME,model=virtio \
        --osinfo $OSINFO \
        --graphics none \
        --console pty,target_type=serial \
        --import \
        --noautoconsole    
}

# Create VMs
create_vm $VM1_NAME
create_vm $VM2_NAME

# Create internal port on the OVS bridge for management (optional)
#ovs-vsctl add-port $BRIDGE_NAME $OVS_INTERNAL_PORT -- set Interface $OVS_INTERNAL_PORT type=internal
#ip link set $OVS_INTERNAL_PORT up
#dhclient $OVS_INTERNAL_PORT

echo "VMs and Open vSwitch setup completed successfully!"

