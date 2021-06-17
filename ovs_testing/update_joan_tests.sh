#!/bin/bash

# script to update XML files for Joan's conntrack tests

rhel_version=$1
if [[ $# -lt 1 ]]; then
	echo "You must include a RHEL version (7 or 8)"
	echo "Example: $0 7"
fi

job_xml_file="job.xml"

FDP_RELEASE="19.G"
RPM_OVS29_RHEL7="http://download-node-02.eng.bos.redhat.com/brewroot/packages/openvswitch/2.9.0/122.el7fdp/x86_64/openvswitch-2.9.0-122.el7fdp.x86_64.rpm"
RPM_OVS211_RHEL7="http://download-node-02.eng.bos.redhat.com/brewroot/packages/openvswitch2.11/2.11.0/24.el7fdp/x86_64/openvswitch2.11-2.11.0-24.el7fdp.x86_64.rpm"
RPM_OVS211_RHEL8="http://download-node-02.eng.bos.redhat.com/brewroot/packages/openvswitch2.11/2.11.0/24.el8fdp/x86_64/openvswitch2.11-2.11.0-24.el8fdp.x86_64.rpm"
RPM_OVS_SELINUX_EXTRA_POLICY_RHEL7="http://download-node-02.eng.bos.redhat.com/brewroot/packages/openvswitch-selinux-extra-policy/1.0/14.el7fdp/noarch/openvswitch-selinux-extra-policy-1.0-14.el7fdp.noarch.rpm"
RPM_OVS_SELINUX_EXTRA_POLICY_RHEL8="http://download-node-02.eng.bos.redhat.com/brewroot/packages/openvswitch-selinux-extra-policy/1.0/19.el8fdp/noarch/openvswitch-selinux-extra-policy-1.0-19.el8fdp.noarch.rpm"
RHEL7_COMPOSE="RHEL-7.7-updates-20191008.0"
RHEL8_COMPOSE="RHEL-8.0.0-20190404.2"



RPM_DPDK=
RPM_DPDK_TOOLS=

sedeasy ()
{
sed -i "s/$(echo $1 | sed -e 's/\([[\/.*]\|\]\)/\\&/g')/$(echo $2 | sed -e 's/[\/&]/\\&/g')/g" $3
}

if [[ "$rhel_version" == "7" ]]; then
	template_file="joan_ovs211_rhel7_conntrack_dpdk_template.xml"
elif [[ "$rhel_version" == "8" ]]; then
	template_file="joan_ovs211_rhel8_conntrack_dpdk_template.xml"
fi
pushd /home/ralongi/Documents/ovs_testing/xml_files/
/bin/cp -f $template_file job.xml
sedeasy "fdp_release" "$FDP_RELEASE" "$job_xml_file"
sedeasy "rhel_compose" "$RHEL7_COMPOSE" "$job_xml_file"
sedeasy "rpm_ovs" "$RPM_OVS211_RHEL7" "$job_xml_file"
sedeasy "rpm_dpdk" "$RPM_DPDK" "joan_ovs211_rhel7_conntrack_dpdk.xml"
sedeasy "rpm_dpdk_tools" "$RPM_DPDK_TOOLS" "joan_ovs211_rhel7_conntrack_dpdk.xml"
sedeasy "ovs_selinux" "$RPM_OVS_SELINUX_EXTRA_POLICY_RHEL7" "joan_ovs211_rhel7_conntrack_dpdk.xml"

bkr job-submit joan_ovs211_rhel7_conntrack_dpdk.xml

popd



