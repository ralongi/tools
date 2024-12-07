#!/bin/bash

# power_cycle_crash

sedeasy ()
{
sed -i "s/$(echo $1 | sed -e 's/\([[\/.*]\|\]\)/\\&/g')/$(echo $2 | sed -e 's/[\/&]/\\&/g')/g" $3
}

pushd /home/ralongi/inf_ralongi/Documents/ovs_testing/xml_files

if [[ "$skip_rhel7_ovs29" != "yes" ]]; then
	# OVS 2.9, RHEL-7
	COMPOSE=$RHEL7_COMPOSE
	RPM_OVS=$RPM_OVS29_RHEL7
	ovs_rpm_name=$(echo $RPM_OVS | awk -F "/" '{print $NF}')	

	/bin/cp -f template_power_cycle_crash_rhel7.xml power_cycle_crash_rhel7.xml
	sedeasy "FDP_RELEASE_VALUE" "$FDP_RELEASE" "power_cycle_crash_rhel7.xml"
	sedeasy "OVS_RPM_VALUE" "$ovs_rpm_name" "power_cycle_crash_rhel7.xml"
	sedeasy "COMPOSE_VALUE" "$COMPOSE" "power_cycle_crash_rhel7.xml"
	sedeasy "RPM_OVS_SELINUX_EXTRA_POLICY_VALUE" "$RPM_OVS_SELINUX_EXTRA_POLICY_RHEL7" "power_cycle_crash_rhel7.xml"
	sedeasy "RPM_OVS_VALUE" "$RPM_OVS" "power_cycle_crash_rhel7.xml"
	bkr job-submit power_cycle_crash_rhel7.xml
fi

if [[ "$skip_rhel7_ovs211" != "yes" ]]; then
	# OVS 2.11, RHEL-7
	COMPOSE=$RHEL7_COMPOSE
	RPM_OVS=$RPM_OVS211_RHEL7
	ovs_rpm_name=$(echo $RPM_OVS | awk -F "/" '{print $NF}')	

	/bin/cp -f template_power_cycle_crash_rhel7.xml power_cycle_crash_rhel7.xml
	sedeasy "FDP_RELEASE_VALUE" "$FDP_RELEASE" "power_cycle_crash_rhel7.xml"
	sedeasy "OVS_RPM_VALUE" "$ovs_rpm_name" "power_cycle_crash_rhel7.xml"
	sedeasy "COMPOSE_VALUE" "$COMPOSE" "power_cycle_crash_rhel7.xml"
	sedeasy "RPM_OVS_SELINUX_EXTRA_POLICY_VALUE" "$RPM_OVS_SELINUX_EXTRA_POLICY_RHEL7" "power_cycle_crash_rhel7.xml"
	sedeasy "RPM_OVS_VALUE" "$RPM_OVS" "power_cycle_crash_rhel7.xml"
	bkr job-submit power_cycle_crash_rhel7.xml
fi

if [[ "$skip_rhel7_ovs213" != "yes" ]]; then
	# OVS 2.13, RHEL-7
	COMPOSE=$RHEL7_COMPOSE
	RPM_OVS=$RPM_OVS213_RHEL7
	ovs_rpm_name=$(echo $RPM_OVS | awk -F "/" '{print $NF}')	

	/bin/cp -f template_power_cycle_crash_rhel7.xml power_cycle_crash_rhel7.xml
	sedeasy "FDP_RELEASE_VALUE" "$FDP_RELEASE" "power_cycle_crash_rhel7.xml"
	sedeasy "OVS_RPM_VALUE" "$ovs_rpm_name" "power_cycle_crash_rhel7.xml"
	sedeasy "COMPOSE_VALUE" "$COMPOSE" "power_cycle_crash_rhel7.xml"
	sedeasy "RPM_OVS_SELINUX_EXTRA_POLICY_VALUE" "$RPM_OVS_SELINUX_EXTRA_POLICY_RHEL7" "power_cycle_crash_rhel7.xml"
	sedeasy "RPM_OVS_VALUE" "$RPM_OVS" "power_cycle_crash_rhel7.xml"
	bkr job-submit power_cycle_crash_rhel7.xml
fi

if [[ "$skip_rhel8_ovs211" != "yes" ]]; then
	# OVS 2.11, RHEL-8
	COMPOSE=$RHEL8_COMPOSE
	RPM_OVS=$RPM_OVS211_RHEL8
	ovs_rpm_name=$(echo $RPM_OVS | awk -F "/" '{print $NF}')	

	/bin/cp -f template_power_cycle_crash_rhel8.xml power_cycle_crash_rhel8.xml
	sedeasy "FDP_RELEASE_VALUE" "$FDP_RELEASE" "power_cycle_crash_rhel8.xml"
	sedeasy "OVS_RPM_VALUE" "$ovs_rpm_name" "power_cycle_crash_rhel8.xml"
	sedeasy "COMPOSE_VALUE" "$COMPOSE" "power_cycle_crash_rhel8.xml"
	sedeasy "RPM_OVS_SELINUX_EXTRA_POLICY_VALUE" "$RPM_OVS_SELINUX_EXTRA_POLICY_RHEL8" "power_cycle_crash_rhel8.xml"
	sedeasy "RPM_OVS_VALUE" "$RPM_OVS" "power_cycle_crash_rhel8.xml"
	bkr job-submit power_cycle_crash_rhel8.xml
fi

if [[ "$skip_rhel8_ovs213" != "yes" ]]; then
	# OVS 2.13, RHEL-8
	COMPOSE=$RHEL8_COMPOSE
	RPM_OVS=$RPM_OVS213_RHEL8
	ovs_rpm_name=$(echo $RPM_OVS | awk -F "/" '{print $NF}')	

	/bin/cp -f template_power_cycle_crash_rhel8.xml power_cycle_crash_rhel8.xml
	sedeasy "FDP_RELEASE_VALUE" "$FDP_RELEASE" "power_cycle_crash_rhel8.xml"
	sedeasy "OVS_RPM_VALUE" "$ovs_rpm_name" "power_cycle_crash_rhel8.xml"
	sedeasy "COMPOSE_VALUE" "$COMPOSE" "power_cycle_crash_rhel8.xml"
	sedeasy "RPM_OVS_SELINUX_EXTRA_POLICY_VALUE" "$RPM_OVS_SELINUX_EXTRA_POLICY_RHEL8" "power_cycle_crash_rhel8.xml"
	sedeasy "RPM_OVS_VALUE" "$RPM_OVS" "power_cycle_crash_rhel8.xml"
	bkr job-submit power_cycle_crash_rhel8.xml
fi

if [[ "$skip_rhel8_ovs215" != "yes" ]]; then
	# OVS 2.15, RHEL-8
	COMPOSE=$RHEL8_COMPOSE
	RPM_OVS=$RPM_OVS215_RHEL8
	ovs_rpm_name=$(echo $RPM_OVS | awk -F "/" '{print $NF}')	

	/bin/cp -f template_power_cycle_crash_rhel8.xml power_cycle_crash_rhel8.xml
	sedeasy "FDP_RELEASE_VALUE" "$FDP_RELEASE" "power_cycle_crash_rhel8.xml"
	sedeasy "OVS_RPM_VALUE" "$ovs_rpm_name" "power_cycle_crash_rhel8.xml"
	sedeasy "COMPOSE_VALUE" "$COMPOSE" "power_cycle_crash_rhel8.xml"
	sedeasy "RPM_OVS_SELINUX_EXTRA_POLICY_VALUE" "$RPM_OVS_SELINUX_EXTRA_POLICY_RHEL8" "power_cycle_crash_rhel8.xml"
	sedeasy "RPM_OVS_VALUE" "$RPM_OVS" "power_cycle_crash_rhel8.xml"
	bkr job-submit power_cycle_crash_rhel8.xml
fi

if [[ "$skip_rhel9_ovs215" != "yes" ]]; then
	# OVS 2.15, RHEL-8
	COMPOSE=$RHEL9_COMPOSE
	RPM_OVS=$RPM_OVS215_RHEL9
	ovs_rpm_name=$(echo $RPM_OVS | awk -F "/" '{print $NF}')
	selinux_enable=no	

	/bin/cp -f template_power_cycle_crash_rhel9.xml power_cycle_crash_rhel9.xml
	sedeasy "FDP_RELEASE_VALUE" "$FDP_RELEASE" "power_cycle_crash_rhel9.xml"
	sedeasy "OVS_RPM_VALUE" "$ovs_rpm_name" "power_cycle_crash_rhel9.xml"
	sedeasy "COMPOSE_VALUE" "$COMPOSE" "power_cycle_crash_rhel9.xml"
	sedeasy "RPM_OVS_SELINUX_EXTRA_POLICY_VALUE" "$RPM_OVS_SELINUX_EXTRA_POLICY_RHEL9" "power_cycle_crash_rhel9.xml"
	sedeasy "RPM_OVS_VALUE" "$RPM_OVS" "power_cycle_crash_rhel9.xml"
	sedeasy "selinux_enable_value" "$selinux_enable" "power_cycle_crash_rhel9.xml"
	bkr job-submit power_cycle_crash_rhel9.xml
fi

popd 2>/dev/null
