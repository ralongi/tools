#!/bin/bash

# ovs_qos

dbg_flag="set -x"
pushd ~/git/my_fork/kernel/networking/openvswitch/ovs_qos
fdp_release=$FDP_RELEASE
server="netqe6.knqe.lab.eng.bos.redhat.com"
client="netqe5.knqe.lab.eng.bos.redhat.com"
server_driver="ixgbe"
client_driver="ixgbe"

# OVS 2.9, RHEL-7
compose=$RHEL7_COMPOSE
RPM_OVS=$RPM_OVS29_RHEL7
image_name=$RHEL7_VM_IMAGE
ovs_rpm_name=$(echo $RPM_OVS | awk -F "/" '{print $NF}')	
rhos_test_version="14"

lstest | runtest $compose  --variant=server --arch=x86_64 --machine=$server,$client --systype=machine,machine  --param=dbg_flag="set -x" --param=NAY=yes --param=PVT=no --param=mh-NIC_DRIVER=$server_driver,$client_driver --param=image_name=$image_name --param=RPM_CONTAINER_SELINUX_POLICY=$RPM_CONTAINER_SELINUX_POLICY --param=RPM_OVS_SELINUX_EXTRA_POLICY=$RPM_OVS_SELINUX_EXTRA_POLICY_RHEL7 --param=RPM_OVS=$RPM_OVS --wb "$fdp_release, $ovs_rpm_name, $compose, openvswitch/ovs_qos, Client driver: $client_driver, Server driver: $server_driver"

# OVS 2.11, RHEL-7
compose=$RHEL7_COMPOSE
RPM_OVS=$RPM_OVS211_RHEL7
image_name=$RHEL7_VM_IMAGE
ovs_rpm_name=$(echo $RPM_OVS | awk -F "/" '{print $NF}')	
rhos_test_version="14"

lstest | runtest $compose  --variant=server --arch=x86_64 --machine=$server,$client --systype=machine,machine  --param=dbg_flag="set -x" --param=NAY=yes --param=PVT=no --param=mh-NIC_DRIVER=$server_driver,$client_driver --param=image_name=$image_name --param=RPM_CONTAINER_SELINUX_POLICY=$RPM_CONTAINER_SELINUX_POLICY --param=RPM_OVS_SELINUX_EXTRA_POLICY=$RPM_OVS_SELINUX_EXTRA_POLICY_RHEL7 --param=RPM_OVS=$RPM_OVS --wb "$fdp_release, $ovs_rpm_name, $compose, openvswitch/ovs_qos, Client driver: $client_driver, Server driver: $server_driver"

# OVS 2.12, RHEL-7
compose=$RHEL7_COMPOSE
RPM_OVS=$RPM_OVS212_RHEL7
image_name=$RHEL7_VM_IMAGE
ovs_rpm_name=$(echo $RPM_OVS | awk -F "/" '{print $NF}')	
rhos_test_version="14"

#lstest | runtest $compose  --variant=server --arch=x86_64 --machine=$server,$client --systype=machine,machine  --param=dbg_flag="set -x" --param=NAY=yes --param=PVT=no --param=mh-NIC_DRIVER=$server_driver,$client_driver --param=image_name=$image_name --param=RPM_CONTAINER_SELINUX_POLICY=$RPM_CONTAINER_SELINUX_POLICY --param=RPM_OVS_SELINUX_EXTRA_POLICY=$RPM_OVS_SELINUX_EXTRA_POLICY_RHEL7 --param=RPM_OVS=$RPM_OVS --wb "$fdp_release, $ovs_rpm_name, $compose, openvswitch/ovs_qos, Client driver: $client_driver, Server driver: $server_driver"

# OVS 2.13, RHEL-7
compose=$RHEL7_COMPOSE
RPM_OVS=$RPM_OVS213_RHEL7
image_name=$RHEL7_VM_IMAGE
ovs_rpm_name=$(echo $RPM_OVS | awk -F "/" '{print $NF}')	
rhos_test_version="14"

#lstest | runtest $compose  --variant=server --arch=x86_64 --machine=$server,$client --systype=machine,machine  --param=dbg_flag="set -x" --param=NAY=yes --param=PVT=no --param=mh-NIC_DRIVER=$server_driver,$client_driver --param=image_name=$image_name --param=RPM_CONTAINER_SELINUX_POLICY=$RPM_CONTAINER_SELINUX_POLICY --param=RPM_OVS_SELINUX_EXTRA_POLICY=$RPM_OVS_SELINUX_EXTRA_POLICY_RHEL7 --param=RPM_OVS=$RPM_OVS --wb "$fdp_release, $ovs_rpm_name, $compose, openvswitch/ovs_qos, Client driver: $client_driver, Server driver: $server_driver"

# OVS 2.11, RHEL-8
compose=$RHEL8_COMPOSE
RPM_OVS=$RPM_OVS211_RHEL8
image_name=$RHEL8_VM_IMAGE
ovs_rpm_name=$(echo $RPM_OVS | awk -F "/" '{print $NF}')	
rhos_test_version="14"
ks_meta="harness='restraint-rhts beakerlib beakerlib-redhat'"

lstest | runtest $compose --repo "http://download.devel.redhat.com/nightly/latest-BUILDROOT-8-RHEL-8/compose/Buildroot/x86_64/os" --variant=BaseOS --arch=x86_64 --ks-meta "$ks_meta" --arch=x86_64 --machine=$server,$client --systype=machine,machine  --param=dbg_flag="set -x" --param=NAY=yes --param=PVT=no --param=mh-NIC_DRIVER=$server_driver,$client_driver --param=image_name=$image_name --param=RPM_OVS_SELINUX_EXTRA_POLICY=$RPM_OVS_SELINUX_EXTRA_POLICY_RHEL7 --param=RPM_OVS=$RPM_OVS --wb "$fdp_release, $ovs_rpm_name, $compose, openvswitch/ovs_qos, Client driver: $client_driver, Server driver: $server_driver"

# OVS 2.12, RHEL-8
compose=$RHEL8_COMPOSE
RPM_OVS=$RPM_OVS212_RHEL8
image_name=$RHEL8_VM_IMAGE
ovs_rpm_name=$(echo $RPM_OVS | awk -F "/" '{print $NF}')	
rhos_test_version="14"
ks_meta="harness='restraint-rhts beakerlib beakerlib-redhat'"

#lstest | runtest $compose --repo "http://download.devel.redhat.com/nightly/latest-BUILDROOT-8-RHEL-8/compose/Buildroot/x86_64/os" --variant=BaseOS --arch=x86_64 --ks-meta "$ks_meta" --arch=x86_64 --machine=$server,$client --systype=machine,machine  --param=dbg_flag="set -x" --param=NAY=yes --param=PVT=no --param=mh-NIC_DRIVER=$server_driver,$client_driver --param=image_name=$image_name --param=RPM_OVS_SELINUX_EXTRA_POLICY=$RPM_OVS_SELINUX_EXTRA_POLICY_RHEL7 --param=RPM_OVS=$RPM_OVS --wb "$fdp_release, $ovs_rpm_name, $compose, openvswitch/ovs_qos, Client driver: $client_driver, Server driver: $server_driver"

# OVS 2.13, RHEL-8
compose=$RHEL8_COMPOSE
RPM_OVS=$RPM_OVS213_RHEL8
image_name=$RHEL8_VM_IMAGE
ovs_rpm_name=$(echo $RPM_OVS | awk -F "/" '{print $NF}')	
rhos_test_version="14"
ks_meta="harness='restraint-rhts beakerlib beakerlib-redhat'"

lstest | runtest $compose --repo "http://download.devel.redhat.com/nightly/latest-BUILDROOT-8-RHEL-8/compose/Buildroot/x86_64/os" --variant=BaseOS --arch=x86_64 --ks-meta "$ks_meta" --arch=x86_64 --machine=$server,$client --systype=machine,machine  --param=dbg_flag="set -x" --param=NAY=yes --param=PVT=no --param=mh-NIC_DRIVER=$server_driver,$client_driver --param=image_name=$image_name --param=RPM_OVS_SELINUX_EXTRA_POLICY=$RPM_OVS_SELINUX_EXTRA_POLICY_RHEL7 --param=RPM_OVS=$RPM_OVS --wb "$fdp_release, $ovs_rpm_name, $compose, openvswitch/ovs_qos, Client driver: $client_driver, Server driver: $server_driver"
	
popd
