#!/bin/bash

# perf
# may need to create proper image for westford or point to bj image

#card_type=$(echo $1 | tr '[:upper:]' '[:lower:]')
#task="/kernel/networking/openvswitch/perf"
#machine="netqe21.knqe.lab.eng.bos.redhat.com,netqe44.knqe.eng.rdu2.dc.redhat.com"
#nic_test="i40e_sriov"
nic_test="mlx5_core_sriov"

pushd ~/git/my_fork/kernel/networking/openvswitch/perf
server="netqe24.knqe.eng.rdu2.dc.redhat.com"
client="netqe25.knqe.eng.rdu2.dc.redhat.com"
ovs_rpm_name=$(echo $RPM_OVS | awk -F "/" '{print $NF}')
if [[ $(echo $server | grep '.bos.redhat') ]]; then
	VM_IMAGE="http://netqe-infra01.knqe.eng.rdu2.dc.redhat.com/vm/$VM_IMAGE"
elif [[ $(echo $server | grep '.pek2.redhat') ]]; then
	VM_IMAGE="http://netqe-bj.usersys.redhat.com/share/vms/$VM_IMAGE"
fi

test_env=http://netqe-infra01.knqe.eng.rdu2.dc.redhat.com/share/ralongi/mlx5_core_sriov_westford

runtest $COMPOSE --arch=x86_64 --servers=1 --clients=1 --machine=$server,$client --systype=machine,machine  --kernel-options-post="pci=realloc intel_iommu=on" --task="/kernel/networking/openvswitch/perf" --param=dbg_flag="set -x" --param=nic_test=$nic_test --param=test_env=$test_env --param=image=$VM_IMAGE --param=rpm_dpdk=$rpm_dpdk --param=rpm_openvswitch_selinux_extra_policy=$RPM_OVS_SELINUX_EXTRA_POLICY --param=rpm_ovs=$RPM_OVS --wb "Pensando SR-IOV, FDP $FDP_RELEASE, $ovs_rpm_name, $COMPOSE, openvswitch/perf" --append-task="/kernel/networking/openvswitch/crash_check {dbg_flag=set -x}"

popd

