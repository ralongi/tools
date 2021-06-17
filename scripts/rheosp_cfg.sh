# configuring OSP after packstack installation

cp keystone_admin keystone_user1
vi keystone_user1
	- change password and admin entries to user1

scp keystone file(s) to any other nodes

select interface on each host, assign IP address accordingly

cfg_static_ip ()
{
	IP4ADDR=$1
	IP6ADDR=$2
	IFACE=$3
	
	grep -i "dhcp" /etc/sysconfig/network-scripts/ifcfg-$IFACE && if [ $? -eq 0 ]; then 
		/bin/cp -f /etc/sysconfig/network-scripts/ifcfg-$IFACE /etc/sysconfig/network-scripts/ifcfg-"$IFACE"_dhcp;
		sed -i -- 's/dhcp/static/g' /etc/sysconfig/network-scripts/ifcfg-$IFACE;
		sed -i -- 's/NM_CONTROLLED=yes/NM_CONTROLLED=no/g' /etc/sysconfig/network-scripts/ifcfg-$IFACE;
		sed -i -- 's/ONBOOT=no/ONBOOT=yes/g' /etc/sysconfig/network-scripts/ifcfg-$IFACE;
		echo "IPADDR=$IP4ADDR" >> /etc/sysconfig/network-scripts/ifcfg-$IFACE;
		echo "NETMASK=255.255.255.0" >> /etc/sysconfig/network-scripts/ifcfg-$IFACE;
		echo "IPV6INIT=yes" >> /etc/sysconfig/network-scripts/ifcfg-$IFACE;
		echo "IPV6ADDR=$IP6ADDR" >> /etc/sysconfig/network-scripts/ifcfg-$IFACE;
		ifdown $IFACE;
		ifup $IFACE;
	else	
		echo "It looks like static IP addresses are already configured on $IFACE." 
	fi
	
	ifdown $IFACE
	ifup $IFACE

}

## cfg_static_ip 192.168.1.7 2001::7 p5p1, etc. on each node

#disable NetworkManager service if it's there

on the network node:

#modify the ifcfg file to contain:

DEVICE=ethx
HWADDR=00:1A:4A:DE:DB:9C
TYPE=OVSPort
DEVICETYPE=ovs
OVS_BRIDGE=br-ex
ONBOOT=yes


#vi /etc/sysconfig/network-scripts/ifcfg-br-ex
DEVICE=br-ex
DEVICETYPE=ovs
TYPE=OVSBridge
BOOTPROTO=static
IPADDR=192.168.1.7
NETMASK=255.255.255.0
ONBOOT=yes

# set up neutron networking.  Execute the following on the network node(s)
cd ~
source keystonerc_admin
neutron net-create private
neutron subnet-create private 192.168.100.0/24 --name private_vmsubnet
neutron net-create public --shared --router:external=True
neutron subnet-create public 192.168.1.0/24 --name public_subnet --enable_dhcp=False --allocation-pool start=192.168.1.20,end=192.168.1.100
neutron router-create router1
neutron router-interface-add router1 private_vmsubnet
neutron router-gateway-set router1 public

# create image using glance
glance image-create --name "rhel6.7" --disk-format qcow2 --container-format bare --location http://pnate-control-01.lab.bos.redhat.com/rhel6.7.qcow2

# launch instance with nova
nova boot rick-1 --flavor 2 --image rhel6.7 --key-name  mykey --num-instances 2 --nic net-id=2c65960f-c222-4820-8628-be0e0e2c9890

obtain HW address from eth1 using "ip a" command, cp ifcfg-eth0 to ifcfg-eth1, edit ifcfg-eth1 to contain:
	DEVICE="eth1"
	BOOTPROTO="dhcp"
	HWADDR="FA:16:3E:AA:8A:96"
	ONBOOT="yes"


