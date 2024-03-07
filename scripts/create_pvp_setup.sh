# First, provision a clean system

###############################################################################
# Run all of the steps below before completing setup of either kernel or netdev

echo "sslverify=false" >> /etc/yum.conf

# install wget in case it's missing
yum -y install wget

# install beaker-client.repo
wget -O /etc/yum.repos.d/beaker-client.repo http://download.lab.bos.redhat.com/beakerrepos/beaker-client-RedHatEnterpriseLinux.repo

# install beaker related packages
yum -y install rhts-test-env beakerlib rhts-devel rhts-python beakerlib-redhat beaker-client beaker-redhat

# create beaker-tasks.repo file
(
	echo [beaker-tasks]
	echo name=beaker-tasks
	echo baseurl=http://beaker.engineering.redhat.com/rpms
	echo enabled=1
	echo gpgcheck=0
	echo skip_if_unavailable=1
) > /etc/yum.repos.d/beaker-tasks.repo

# install target packages (example below is for setting up typical PVP test on a system)
yum -y install kernel-networking-common kernel-networking-openvswitch-common  kernel-networking-openvswitch-memory_leak_soak

pushd /mnt/tests/kernel/networking/openvswitch/memory_leak_soak/
source ../../common/include.sh
source ./env.sh || exit 1
source ../common/install.sh || exit 1
source ../common/pvt_networking_common.sh || exit 1
source ../common/package_list.sh || exit 1

rhel_version=$(cut -f1 -d. /etc/redhat-release | sed 's/[^0-9]//g')
vm_list=${vm_list:-"g1"}
flows_file="/tmp/flows.txt"
ovsbr="ovsbr0"
iface1="p3p1"
iface2="p3p2"
RPM_OVS_SELINUX_EXTRA_POLICY=$OVS_SELINUX_20I_RHEL8
RPM_OVS=$OVS211_20I_RHEL8
yum -y remove openvswitch* || true
yum -y install $RPM_OVS_SELINUX_EXTRA_POLICY $RPM_OVS
systemctl enable openvswitch
systemctl start openvswitch

if [[ $rhel_version -eq 7 ]]; then
    get_latest_qemu_packages
    qemu_package_list="$latest_qemu_kvm_rhev_rpm $latest_qemu_img_rhev_rpm $latest_qemu_kvm_common_rhev_rpm"
    for i in $qemu_package_list; do
		rpm=${i##*/}
		package=${rpm%.*}
		rpm -q $package
		echo $? | tee /tmp/pkg_result.txt
   	done
   	if [[ $(grep -v 0 /tmp/pkg_result.txt) ]]; then
   		yum -y install $qemu_package_list
   	else
   		echo "All qemu packages are already installed"
   	fi
else
	rpm -q qemu-kvm
	if [[ $? -ne 0 ]]; then yum -y install qemu-kvm; fi
	rpm -q libvirt
    if [[ $? -ne 0 ]]; then yum -y install libvirt; fi
fi

systemctl restart libvirtd

get_vm_vcpu_info
ovs-ofctl del-flows $ovsbr
rm -f $flows_file
ovs-vsctl --if-exists del-br $ovsbr
ovs-vsctl add-br $ovsbr

# Run all of the steps above before completing setup of either kernel or netdev
###############################################################################

# Basic setup with two VMs attached to one OVS bridge

vi /home/g1.xml
  
<domain type='kvm'>
  <name>g1</name>
  <memory unit='KiB'>4194304</memory>
  <vcpu placement='static'>3</vcpu>
  <os>
    <type arch='x86_64' machine='pc'>hvm</type>
    <boot dev='hd'/>
  </os>
  <features>
    <acpi/>
    <apic/>
    <pae/>
  </features>
  <cpu mode='host-passthrough'>
  </cpu>
  <clock offset='utc'/>
  <on_poweroff>destroy</on_poweroff>
  <on_reboot>restart</on_reboot>
  <on_crash>restart</on_crash>
  <devices>
    <emulator>/usr/libexec/qemu-kvm</emulator>
    <disk type='file' device='disk'>
      <driver name='qemu' type='qcow2' cache='none'/>
      <source file='/var/lib/libvirt/images/g1.qcow2'/>
      <target dev='vda' bus='virtio'/>
    </disk>
    <interface type='bridge'>
      <source bridge='ovsbr0'/>
      <virtualport type='openvswitch'>
      <parameters/>
      </virtualport>
      <target dev='vnet0'/>
      <model type='virtio'/>
      <alias name='net0'/>
     </interface>
    <serial type='pty'>
      <target port='0'/>
    </serial>
    <console type='pty'>
      <target type='serial' port='0'/>
    </console>
    <input type='tablet' bus='usb'/>
    <input type='mouse' bus='ps2'/>
    <graphics type='vnc' port='-1' autoport='yes'/>
    <memballoon model='virtio'>
      <address type='pci' domain='0x0000' bus='0x00' slot='0x06'
function='0x0'/>
    </memballoon>
  </devices>
</domain>

vi /home/g2.xml

<domain type='kvm'>
  <name>g2</name>
  <memory unit='KiB'>4194304</memory>
  <vcpu placement='static'>3</vcpu>
  <os>
    <type arch='x86_64' machine='pc'>hvm</type>
    <boot dev='hd'/>
  </os>
  <features>
    <acpi/>
    <apic/>
    <pae/>
  </features>
  <cpu mode='host-passthrough'>
  </cpu>
  <clock offset='utc'/>
  <on_poweroff>destroy</on_poweroff>
  <on_reboot>restart</on_reboot>
  <on_crash>restart</on_crash>
  <devices>
    <emulator>/usr/libexec/qemu-kvm</emulator>
    <disk type='file' device='disk'>
      <driver name='qemu' type='qcow2' cache='none'/>
      <source file='/var/lib/libvirt/images/g2.qcow2'/>
      <target dev='vda' bus='virtio'/>
    </disk>
    <interface type='bridge'>
      <source bridge='ovsbr0'/>
      <virtualport type='openvswitch'>
      <parameters/>
      </virtualport>
      <target dev='vnet0'/>
      <model type='virtio'/>
      <alias name='net0'/>
     </interface>
    <serial type='pty'>
      <target port='0'/>
    </serial>
    <console type='pty'>
      <target type='serial' port='0'/>
    </console>
    <input type='tablet' bus='usb'/>
    <input type='mouse' bus='ps2'/>
    <graphics type='vnc' port='-1' autoport='yes'/>
    <memballoon model='virtio'>
      <address type='pci' domain='0x0000' bus='0x00' slot='0x06'
function='0x0'/>
    </memballoon>
  </devices>
</domain>

wget -O /var/lib/libvirt/images/g1.qcow2 http://netqe-infra01.knqe.eng.rdu2.dc.redhat.com/share/vms/OVS/rhel8.2.qcow2_large
cp /var/lib/libvirt/images/g1.qcow2 /var/lib/libvirt/images/g2.qcow2
virsh define /home/g1.xml
virsh define /home/g2.xml
systemctl start openvswitch
ovs-vsctl add-br ovsbr0
virsh start g1
virsh start g2

ovs-ofctl add-flow ovsbr0 in_port=vnet0,actions=vnet1
ovs-ofctl add-flow ovsbr0 in_port=vnet1,actions=vnet0

#on g1
virsh console g1 (root/redhat)
ip addr add dev ens3 192.168.100.1/24

# on g2
virsh console g2 (root/redhat)
ip addr add dev ens3 192.168.100.2/24

# then ping between the VMs

#on g1
ping 192.168.100.2

#on g2
ping 192.168.100.1

###############################################################################

# kernel datapath PVP
export use_dpdk="no"
remove_existing_vms
for i in $vm_list; do create_vm $i; done
ovs_kernel_datapath_topo_config
echo "in_port=1005,idle_timeout=0,actions=output:1015" >> $flows_file
echo "in_port=1015,idle_timeout=0,actions=output:1005" >> $flows_file
echo "in_port=1010,idle_timeout=0,actions=output:1020" >> $flows_file
echo "in_port=1020,idle_timeout=0,actions=output:1010" >> $flows_file
ovs-ofctl add-flows $ovsbr $flows_file
ip link set dev $ovsbr up 
for i in $vm_list; do run_testpmd $i; done

/root/testpmd.sh -n 2 -c 3 -q 1 -m 1024 0000:00:03.0 0000:00:04.0

###############################################################################

# netdev datapath PVP
export use_dpdk="yes"
dpdk_netdev_datapath_topo_config
remove_existing_vms	
for i in $vm_list; do create_vm $i; done    
ovs-ofctl del-flows $ovsbr
rm -f $flows_file
echo "in_port=1,idle_timeout=0,actions=output:2" >> $flows_file
echo "in_port=2,idle_timeout=0,actions=output:1" >> $flows_file
echo "in_port=3,idle_timeout=0,actions=output:4" >> $flows_file
echo "in_port=4,idle_timeout=0,actions=output:3" >> $flows_file
ovs-ofctl add-flows $ovsbr $flows_file
ip link set dev $ovsbr up
ip link set dev ovs-netdev up
for i in $vm_list; do run_testpmd $i; done



