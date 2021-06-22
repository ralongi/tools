#!/bin/bash

# power_cycle_crash
# confirm that the correct DUT is specified in the template XML file referenced below

ovs_rpm_name=$(echo $RPM_OVS | awk -F "/" '{print $NF}')

sedeasy ()
{
sed -i "s/$(echo $1 | sed -e 's/\([[\/.*]\|\]\)/\\&/g')/$(echo $2 | sed -e 's/[\/&]/\\&/g')/g" $3
}

pushd /home/ralongi/inf_ralongi/Documents/ovs_testing/xml_files

/bin/cp -f template_power_cycle_crash_rhel$RHEL_VER_MAJOR.xml power_cycle_crash_rhel$RHEL_VER_MAJOR.xml
sedeasy "SELINUX_VALUE" "$SELINUX" "power_cycle_crash_rhel$RHEL_VER_MAJOR.xml"
sedeasy "FDP_RELEASE_VALUE" "$FDP_RELEASE" "power_cycle_crash_rhel$RHEL_VER_MAJOR.xml"
sedeasy "OVS_RPM_VALUE" "$ovs_rpm_name" "power_cycle_crash_rhel$RHEL_VER_MAJOR.xml"
sedeasy "COMPOSE_VALUE" "$COMPOSE" "power_cycle_crash_rhel$RHEL_VER_MAJOR.xml"
sedeasy "RPM_OVS_SELINUX_EXTRA_POLICY_VALUE" "$RPM_OVS_SELINUX_EXTRA_POLICY" "power_cycle_crash_rhel$RHEL_VER_MAJOR.xml"
sedeasy "RPM_OVS_VALUE" "$RPM_OVS" "power_cycle_crash_rhel$RHEL_VER_MAJOR.xml"
bkr job-submit power_cycle_crash_rhel$RHEL_VER_MAJOR.xml

popd
