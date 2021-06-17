#!/bin/bash

# script to update all package URLs in /home/ralongi/Documents/ovs_testing/my_ovs_tests.txt

set -x

sedeasy ()
{
sed -i "s/$(echo $1 | sed -e 's/\([[\/.*]\|\]\)/\\&/g')/$(echo $2 | sed -e 's/[\/&]/\\&/g')/g" $3
} 

FDP_RELEASE="20.A"
RPM_OVS29_RHEL7="http://download-node-02.eng.bos.redhat.com/brewroot/packages/openvswitch/2.9.0/124.el7fdp/x86_64/openvswitch-2.9.0-124.el7fdp.x86_64.rpm"
RPM_OVS211_RHEL7="http://download.eng.bos.redhat.com/brewroot/packages/openvswitch2.11/2.11.0/35.el7fdp/x86_64/openvswitch2.11-2.11.0-35.el7fdp.x86_64.rpm"
RPM_OVS212_RHEL7="http://download.eng.bos.redhat.com/brewroot/packages/openvswitch2.12/2.12.0/12.el7fdp/x86_64/openvswitch2.12-2.12.0-12.el7fdp.x86_64.rpm"
RPM_OVS211_RHEL8="http://download.eng.bos.redhat.com/brewroot/packages/openvswitch2.11/2.11.0/35.el8fdp/x86_64/openvswitch2.11-2.11.0-35.el8fdp.x86_64.rpm"
RPM_OVS212_RHEL8="http://download.eng.bos.redhat.com/brewroot/packages/openvswitch2.12/2.12.0/12.el8fdp/x86_64/openvswitch2.12-2.12.0-12.el8fdp.x86_64.rpm"
RPM_OVS_SELINUX_EXTRA_POLICY_RHEL7="http://download-node-02.eng.bos.redhat.com/brewroot/packages/openvswitch-selinux-extra-policy/1.0/14.el7fdp/noarch/openvswitch-selinux-extra-policy-1.0-14.el7fdp.noarch.rpm"
RPM_OVS_SELINUX_EXTRA_POLICY_RHEL8="http://download-node-02.eng.bos.redhat.com/brewroot/packages/openvswitch-selinux-extra-policy/1.0/19.el8fdp/noarch/openvswitch-selinux-extra-policy-1.0-19.el8fdp.noarch.rpm"
RHEL7_COMPOSE="RHEL-7.7-updates-20191119.2"
RHEL8_COMPOSE="RHEL-8.1.0-20191015.0"

for i in $( grep 'fdp_release=' /home/ralongi/Documents/ovs_testing/my_ovs_tests.txt | awk -F "=" '{print $2}' | awk '{print $2}' | tr -d '"'); do sedeasy "$i" "$FDP_RELEASE" "/home/ralongi/Documents/ovs_testing/my_ovs_tests.txt"; done

for i in $(grep 'compose=' /home/ralongi/Documents/ovs_testing/my_ovs_tests.txt | grep RHEL-7 | awk -F "=" '{print $2}'); do sedeasy "$i" "$RHEL7_COMPOSE" "/home/ralongi/Documents/ovs_testing/my_ovs_tests.txt"; done

for i in $(grep 'compose=' /home/ralongi/Documents/ovs_testing/my_ovs_tests.txt | grep RHEL-8 | awk -F "=" '{print $2}'); do sedeasy "$i" "$RHEL8_COMPOSE" "/home/ralongi/Documents/ovs_testing/my_ovs_tests.txt"; done

for i in $(grep 'RPM_OVS=http' /home/ralongi/Documents/ovs_testing/my_ovs_tests.txt | grep el7 | grep '2.9.0' | awk -F "=" '{print $2}'); do sedeasy "$i" "$RPM_OVS29_RHEL7" "/home/ralongi/Documents/ovs_testing/my_ovs_tests.txt"; done

for i in $(grep 'RPM_OVS=http' /home/ralongi/Documents/ovs_testing/my_ovs_tests.txt | grep el7 | grep '2.11.0' | awk -F "=" '{print $2}'); do sedeasy "$i" "$RPM_OVS211_RHEL7" "/home/ralongi/Documents/ovs_testing/my_ovs_tests.txt"; done

for i in $(grep 'RPM_OVS=http' /home/ralongi/Documents/ovs_testing/my_ovs_tests.txt | grep el7 | grep '2.12.0' | awk -F "=" '{print $2}'); do sedeasy "$i" "$RPM_OVS212_RHEL7" "/home/ralongi/Documents/ovs_testing/my_ovs_tests.txt"; done

for i in $(grep 'RPM_OVS=http' /home/ralongi/Documents/ovs_testing/my_ovs_tests.txt | grep el8 | grep '2.11.0' | awk -F "=" '{print $2}'); do sedeasy "$i" "$RPM_OVS211_RHEL8" "/home/ralongi/Documents/ovs_testing/my_ovs_tests.txt"; done

for i in $(grep 'RPM_OVS=http' /home/ralongi/Documents/ovs_testing/my_ovs_tests.txt | grep el8 | grep '2.12.0' | awk -F "=" '{print $2}'); do sedeasy "$i" "$RPM_OVS212_RHEL8" "/home/ralongi/Documents/ovs_testing/my_ovs_tests.txt"; done

for i in $(grep 'RPM_OVS_SELINUX_EXTRA_POLICY=http' /home/ralongi/Documents/ovs_testing/my_ovs_tests.txt | grep el7 | awk -F "=" '{print $2}'); do sedeasy "$i" "$RPM_OVS_SELINUX_EXTRA_POLICY_RHEL7" "/home/ralongi/Documents/ovs_testing/my_ovs_tests.txt"; done

for i in $(grep 'RPM_OVS_SELINUX_EXTRA_POLICY=http' /home/ralongi/Documents/ovs_testing/my_ovs_tests.txt | grep el8 | awk -F "=" '{print $2}'); do sedeasy "$i" "$RPM_OVS_SELINUX_EXTRA_POLICY_RHEL8" "/home/ralongi/Documents/ovs_testing/my_ovs_tests.txt"; done




