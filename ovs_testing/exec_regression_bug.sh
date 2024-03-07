#!/bin/bash

dbg_flag=${dbg_flag:-"set -x"}
$dbg_flag

ovs_rpm_name=$(echo $RPM_OVS | awk -F "/" '{print $NF}')

sedeasy ()
{
sed -i "s/$(echo $1 | sed -e 's/\([[\/.*]\|\]\)/\\&/g')/$(echo $2 | sed -e 's/[\/&]/\\&/g')/g" $3
}

pushd /home/ralongi/github/tools/ovs_testing/xml_files

/bin/cp -f template_regression_bug_rhel"$RHEL_VER_MAJOR".xml regression_bug_rhel"$RHEL_VER_MAJOR".xml
sedeasy "RPM_OVS_NAME_VALUE" "$ovs_rpm_name" "regression_bug_rhel"$RHEL_VER_MAJOR".xml"
sedeasy "FDP_RELEASE_VALUE" "$FDP_RELEASE" "regression_bug_rhel"$RHEL_VER_MAJOR".xml"
sedeasy "RPM_OVS_VALUE" "$RPM_OVS" "regression_bug_rhel"$RHEL_VER_MAJOR".xml"
sedeasy "COMPOSE_VALUE" "$COMPOSE" "regression_bug_rhel"$RHEL_VER_MAJOR".xml"
sedeasy "RPM_OVS_SELINUX_EXTRA_POLICY_VALUE" "$RPM_OVS_SELINUX_EXTRA_POLICY" "regression_bug_rhel"$RHEL_VER_MAJOR".xml"
sedeasy "RPM_DPDK_VALUE" "$RPM_DPDK" "regression_bug_rhel"$RHEL_VER_MAJOR".xml"
sedeasy "RPM_DPDK_TOOL_VALUE" "$RPM_DPDK_TOOLS" "regression_bug_rhel"$RHEL_VER_MAJOR".xml"
sedeasy "GUEST_IMG_VALUE" "$RHEL_VER" "regression_bug_rhel"$RHEL_VER_MAJOR".xml"
bkr job-submit regression_bug_rhel"$RHEL_VER_MAJOR".xml

popd
