#!/bin/bash

# download git repo
cd /mnt/tests && git clone git://pkgs.devel.redhat.com/tests/kernel

export vm_image_name="rhel7.2.qcow2"
export vm_xml_file="vm_rhel72.xml"

cd /mnt/tests/kernel/networking/openvswitch/tests/mcast_snoop && make run

