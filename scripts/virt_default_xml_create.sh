#!/bin/bash

## script to create a default.xml file to be used for creating a default network for VM.  File may need to be created in an appropriate libvirt directory

cat << EOT > default.xml
<network>
<name>default</name>
<forward mode='nat'>
<nat>
<port start='1024' end='65535'/>
</nat>
</forward>
<bridge name='virbr0' stp='on' delay='0' />
<ip address='192.168.122.1' netmask='255.255.255.0'>
<dhcp>

</dhcp>
</ip>
</network>
EOT

virsh net-define default.xml
virsh net-list
virsh net-autostart default
virsh net-start default

## You can now execute a script to create a VM
