#!/bin/bash

## script to create a default.xml file in /tmp to be used for creating a default network for VM.  File may need to be copied to appropriate libvirt directory

cat << EOT > /tmp/default.xml
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

