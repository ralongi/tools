#!/bin/bash

# perf
# may need to create proper image for westford or point to bj image

dbg_flag="set -x"
card_type=$(echo $1 | tr '[:upper:]' '[:lower:]')

pushd ~/git/kernel/networking/openvswitch/perf
server="netqe24.knqe.lab.eng.bos.redhat.com"
client="netqe25.knqe.lab.eng.bos.redhat.com"
ovs_rpm_name=$(echo $RPM_OVS | awk -F "/" '{print $NF}')
if [[ $(echo $server | grep '.bos.redhat') ]]; then
	VM_IMAGE="http://netqe-infra01.knqe.lab.eng.bos.redhat.com/vm/$VM_IMAGE"
elif [[ $(echo $server | grep '.pek2.redhat') ]]; then
	VM_IMAGE="http://netqe-bj.usersys.redhat.com/share/vms/$VM_IMAGE"
fi

if [[ $card_type == "cx5" ]]; then
	test_env=http://netqe-infra01.knqe.lab.eng.bos.redhat.com/share/ralongi/mlx5_100g_cx5_westford_endurance
	nic_test=mlx5_100g_cx5
elif [[ $card_type == "cx6" ]]; then
	test_env=http://netqe-infra01.knqe.lab.eng.bos.redhat.com/share/ralongi/mlx5_100g_cx6_westford_endurance
	nic_test=mlx5_100g_cx6
fi

lstest | runtest $COMPOSE --arch=x86_64 --machine=$server,$client --systype=machine,machine  --param=dbg_flag="set -x" --param=nic_test=$nic_test --param=test_env=$test_env --param=image=$VM_IMAGE --param=rpm_dpdk=$rpm_dpdk --param=rpm_openvswitch_selinux_extra_policy=$RPM_OVS_SELINUX_EXTRA_POLICY --param=rpm_ovs=$RPM_OVS --wb "FDP $FDP_RELEASE, $ovs_rpm_name, $COMPOSE, openvswitch/perf Endurance"

popd

