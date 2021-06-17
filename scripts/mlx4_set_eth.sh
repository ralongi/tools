#!/bin/bash

# make sure necessary packages are installed to support Mellanox Firmware Tools
yum -y install gcc rpm-build kernel-devel

# download and install Mellanox Firmware Tools
cd /home; wget http://pnate-control-01.lab.bos.redhat.com/mft-4.0.0-53.tgz; tar xzvf mft-4.0.0-53.tgz; rm -f /home/mft-4.0.0-53.tgz
cd mft-4.0.0-53; ./install.sh

# launch Mellanox tools and make the necessary changes so that both interfaces will boot to "eth" by default
mst start
mst_target=$(mst status -v | grep pcicon | awk '{ print $2 }')

mlxconfig -d $mst_target -y set LINK_TYPE_P1=2 LINK_TYPE_P2=2

# Then reboot the system for the changes to take effect
reboot
