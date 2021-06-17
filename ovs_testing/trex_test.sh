
ovsbr="ovsbr0"

virsh destroy vm2
ovs-vsctl --if-exists del-br $ovsbr
ovs-vsctl add-br $ovsbr
ovs-vsctl add-port $ovsbr p2p1 -- set interface p2p1 ofport_request=10
ovs-vsctl add-port $ovsbr p2p2 -- set interface p2p2 ofport_request=11
virsh start vm2
sleep 30
ovs-vsctl --if-exists del-port $ovsbr vnet0
ovs-vsctl --if-exists del-port $ovsbr vnet1
ovs-vsctl add-port $ovsbr vnet0 -- set interface vnet0 ofport_request=20
ovs-vsctl add-port $ovsbr vnet1 -- set interface vnet1 ofport_request=21
ovs-ofctl -O OpenFlow13 --timeout 10 add-flow $ovsbr in_port=10,idle_timeout=0,action=output:20
ovs-ofctl -O OpenFlow13 --timeout 10 add-flow $ovsbr in_port=21,idle_timeout=0,action=output:11

# Add two flow rules below to create bidirectional traffic
ovs-ofctl -O OpenFlow13 --timeout 10 add-flow $ovsbr in_port=20,idle_timeout=0,action=output:10
ovs-ofctl -O OpenFlow13 --timeout 10 add-flow $ovsbr in_port=11,idle_timeout=0,action=output:21


# on VM to run testpmd
modprobe vfio enable_unsafe_noiommu_mode=Y
modprobe vfio-pci
dpdk-devbind -b vfio-pci 0000:00:03.0 0000:00:04.0
sysctl vm.nr_hugepages=2048
testpmd -l 0,1,2 -w 00:03.0 -w 00:04.0  -n4 --socket-mem 1024 -- --burst=64 -i --txqflags=0xf00 --rxd=512 --txd=512 --nb-cores=2 --rxq=1 --txq=1 --disable-hw-vlan --disable-rss

