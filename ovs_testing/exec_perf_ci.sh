#!/bin/bash

dbg_flag=${dbg_flag:-"set +x"}
$dbg_flag

card_type=$(echo $1 | tr '[:upper:]' '[:lower:]')
ovs_rpm_name=$(echo $RPM_OVS | awk -F "/" '{print $NF}')

VM_IMAGE="http://netqe-infra01.knqe.lab.eng.bos.redhat.com/share/vms/OVS/$VM_IMAGE"

if [[ $card_type == "cx5" ]]; then
	test_env=http://netqe-infra01.knqe.lab.eng.bos.redhat.com/share/ralongi/mlx5_100g_cx5_westford
	nic_test=mlx5_100g_cx5
elif [[ $card_type == "cx6" ]]; then
	test_env=http://netqe-infra01.knqe.lab.eng.bos.redhat.com/share/ralongi/mlx5_100g_cx6_westford
	nic_test=mlx5_100g_cx6
fi

sedeasy ()
{
sed -i "s/$(echo $1 | sed -e 's/\([[\/.*]\|\]\)/\\&/g')/$(echo $2 | sed -e 's/[\/&]/\\&/g')/g" $3
}

pushd /home/ralongi/github/tools/ovs_testing/xml_files

/bin/cp -f template_perf_ci_rhel"$RHEL_VER_MAJOR".xml perf_ci_rhel"$RHEL_VER_MAJOR"_$card_type.xml
sedeasy "SELINUX_VALUE" "$SELINUX" "perf_ci_rhel"$RHEL_VER_MAJOR"_$card_type.xml"
sedeasy "RPM_OVS_NAME_VALUE" "$ovs_rpm_name" "perf_ci_rhel"$RHEL_VER_MAJOR"_$card_type.xml"
sedeasy "FDP_RELEASE_VALUE" "$FDP_RELEASE" "perf_ci_rhel"$RHEL_VER_MAJOR"_$card_type.xml"
sedeasy "RPM_OVS_VALUE" "$RPM_OVS" "perf_ci_rhel"$RHEL_VER_MAJOR"_$card_type.xml"
sedeasy "COMPOSE_VALUE" "$COMPOSE" "perf_ci_rhel"$RHEL_VER_MAJOR"_$card_type.xml"
sedeasy "RPM_OVS_SELINUX_EXTRA_POLICY_VALUE" "$RPM_OVS_SELINUX_EXTRA_POLICY" "perf_ci_rhel"$RHEL_VER_MAJOR"_$card_type.xml"
sedeasy "SELINUX_VALUE" "$SELINUX" "perf_ci_rhel"$RHEL_VER_MAJOR"_$card_type.xml"
sedeasy "RPM_DPDK_VALUE" "$RPM_DPDK" "perf_ci_rhel"$RHEL_VER_MAJOR"_$card_type.xml"
sedeasy "VM_IMAGE_VALUE" "$VM_IMAGE" "perf_ci_rhel"$RHEL_VER_MAJOR"_$card_type.xml"
sedeasy "TEST_ENV_VALUE" "$test_env" "perf_ci_rhel"$RHEL_VER_MAJOR"_$card_type.xml"
sedeasy "NIC_TEST_VALUE" "$nic_test" "perf_ci_rhel"$RHEL_VER_MAJOR"_$card_type.xml"
bkr job-submit perf_ci_rhel"$RHEL_VER_MAJOR"_$card_type.xml

popd
