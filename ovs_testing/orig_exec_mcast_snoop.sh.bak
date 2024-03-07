#!/bin/bash

# mcast_snoop

dbg_flag="set -x"
pushd ~/git/kernel/networking/tools/runtest-network
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

cat ovs.list | egrep "openvswitch/mcast_snoop" | runtest $compose  --variant=server --arch=x86_64 --machine=$server,$client --systype=machine,machine  --param=dbg_flag="set -x" --param=NAY=yes --param=PVT=no --param=image_name=$image_name --param=rhos_test_version=$rhos_test_version --param=RPM_CONTAINER_SELINUX_POLICY=$RPM_CONTAINER_SELINUX_POLICY --param=RPM_OVS_SELINUX_EXTRA_POLICY=$RPM_OVS_SELINUX_EXTRA_POLICY_RHEL7 --param=RPM_OVS=$RPM_OVS --param=OVS_SKIP_CLEANUP_ENV=yes --param=mh-NIC_DRIVER=$server_driver,$client_driver --wb "$fdp_release, $ovs_rpm_name, $compose, openvswitch/mcast_snoop, Client driver: $client_driver, Server driver: $server_driver"

# OVS 2.11, RHEL-7
compose=$RHEL7_COMPOSE
RPM_OVS=$RPM_OVS211_RHEL7
image_name=$RHEL7_VM_IMAGE
ovs_rpm_name=$(echo $RPM_OVS | awk -F "/" '{print $NF}')	
rhos_test_version="14"

cat ovs.list | egrep "openvswitch/mcast_snoop" | runtest $compose  --variant=server --arch=x86_64 --machine=$server,$client --systype=machine,machine  --param=dbg_flag="set -x" --param=NAY=yes --param=PVT=no --param=image_name=$image_name --param=rhos_test_version=$rhos_test_version --param=RPM_CONTAINER_SELINUX_POLICY=$RPM_CONTAINER_SELINUX_POLICY --param=RPM_OVS_SELINUX_EXTRA_POLICY=$RPM_OVS_SELINUX_EXTRA_POLICY_RHEL7 --param=RPM_OVS=$RPM_OVS --param=OVS_SKIP_CLEANUP_ENV=yes --param=mh-NIC_DRIVER=$server_driver,$client_driver --wb "$fdp_release, $ovs_rpm_name, $compose, openvswitch/mcast_snoop, Client driver: $client_driver, Server driver: $server_driver"

# OVS 2.12, RHEL-7
compose=$RHEL7_COMPOSE
RPM_OVS=$RPM_OVS212_RHEL7
image_name=$RHEL7_VM_IMAGE
ovs_rpm_name=$(echo $RPM_OVS | awk -F "/" '{print $NF}')	
rhos_test_version="14"

#cat ovs.list | egrep "openvswitch/mcast_snoop" | runtest $compose  --variant=server --arch=x86_64 --machine=$server,$client --systype=machine,machine  --param=dbg_flag="set -x" --param=NAY=yes --param=PVT=no --param=image_name=$image_name --param=rhos_test_version=$rhos_test_version --param=RPM_CONTAINER_SELINUX_POLICY=$RPM_CONTAINER_SELINUX_POLICY --param=RPM_OVS_SELINUX_EXTRA_POLICY=$RPM_OVS_SELINUX_EXTRA_POLICY_RHEL7 --param=RPM_OVS=$RPM_OVS --param=OVS_SKIP_CLEANUP_ENV=yes --param=mh-NIC_DRIVER=$server_driver,$client_driver --wb "$fdp_release, $ovs_rpm_name, $compose, openvswitch/mcast_snoop, Client driver: $client_driver, Server driver: $server_driver"

# OVS 2.13, RHEL-7
compose=$RHEL7_COMPOSE
RPM_OVS=$RPM_OVS213_RHEL7
image_name=$RHEL7_VM_IMAGE
ovs_rpm_name=$(echo $RPM_OVS | awk -F "/" '{print $NF}')	
rhos_test_version="14"

#cat ovs.list | egrep "openvswitch/mcast_snoop" | runtest $compose  --variant=server --arch=x86_64 --machine=$server,$client --systype=machine,machine  --param=dbg_flag="set -x" --param=NAY=yes --param=PVT=no --param=image_name=$image_name --param=rhos_test_version=$rhos_test_version --param=RPM_CONTAINER_SELINUX_POLICY=$RPM_CONTAINER_SELINUX_POLICY --param=RPM_OVS_SELINUX_EXTRA_POLICY=$RPM_OVS_SELINUX_EXTRA_POLICY_RHEL7 --param=RPM_OVS=$RPM_OVS --param=OVS_SKIP_CLEANUP_ENV=yes --param=mh-NIC_DRIVER=$server_driver,$client_driver --wb "$fdp_release, $ovs_rpm_name, $compose, openvswitch/mcast_snoop, Client driver: $client_driver, Server driver: $server_driver"

# OVS 2.11, RHEL-8
compose=$RHEL8_COMPOSE
RPM_OVS=$RPM_OVS211_RHEL8
image_name=$RHEL8_VM_IMAGE
ovs_rpm_name=$(echo $RPM_OVS | awk -F "/" '{print $NF}')	
rhos_test_version="14"
ks_meta="harness='restraint-rhts beakerlib beakerlib-redhat'"

cat ovs.list | egrep "openvswitch/mcast_snoop" | runtest $compose  --repo "http://download.devel.redhat.com/nightly/latest-BUILDROOT-8-RHEL-8/compose/Buildroot/x86_64/os" --variant=BaseOS --arch=x86_64 --ks-meta "$ks_meta" --machine=$server,$client --systype=machine,machine  --param=dbg_flag="set -x" --param=NAY=yes --param=PVT=no --param=image_name=$image_name --param=RPM_OVS_SELINUX_EXTRA_POLICY=$RPM_OVS_SELINUX_EXTRA_POLICY_RHEL8 --param=RPM_OVS=$RPM_OVS --param=mh-NIC_DRIVER=$server_driver,$client_driver --wb "$fdp_release, $ovs_rpm_name, $compose, openvswitch/mcast_snoop, Client driver: $client_driver, Server driver: $server_driver"

# OVS 2.12, RHEL-8
compose=$RHEL8_COMPOSE
RPM_OVS=$RPM_OVS212_RHEL8
image_name=$RHEL8_VM_IMAGE
ovs_rpm_name=$(echo $RPM_OVS | awk -F "/" '{print $NF}')	
rhos_test_version="14"
ks_meta="harness='restraint-rhts beakerlib beakerlib-redhat'"

#cat ovs.list | egrep "openvswitch/mcast_snoop" | runtest $compose  --repo "http://download.devel.redhat.com/nightly/latest-BUILDROOT-8-RHEL-8/compose/Buildroot/x86_64/os" --variant=BaseOS --arch=x86_64 --ks-meta "$ks_meta" --machine=$server,$client --systype=machine,machine  --param=dbg_flag="set -x" --param=NAY=yes --param=PVT=no --param=image_name=$image_name --param=RPM_OVS_SELINUX_EXTRA_POLICY=$RPM_OVS_SELINUX_EXTRA_POLICY_RHEL8 --param=RPM_OVS=$RPM_OVS --param=mh-NIC_DRIVER=$server_driver,$client_driver --wb "$fdp_release, $ovs_rpm_name, $compose, openvswitch/mcast_snoop, Client driver: $client_driver, Server driver: $server_driver"

# OVS 2.13, RHEL-8
compose=$RHEL8_COMPOSE
RPM_OVS=$RPM_OVS213_RHEL8
image_name=$RHEL8_VM_IMAGE
ovs_rpm_name=$(echo $RPM_OVS | awk -F "/" '{print $NF}')	
rhos_test_version="14"
ks_meta="harness='restraint-rhts beakerlib beakerlib-redhat'"

cat ovs.list | egrep "openvswitch/mcast_snoop" | runtest $compose  --repo "http://download.devel.redhat.com/nightly/latest-BUILDROOT-8-RHEL-8/compose/Buildroot/x86_64/os" --variant=BaseOS --arch=x86_64 --ks-meta "$ks_meta" --machine=$server,$client --systype=machine,machine  --param=dbg_flag="set -x" --param=NAY=yes --param=PVT=no --param=image_name=$image_name --param=RPM_OVS_SELINUX_EXTRA_POLICY=$RPM_OVS_SELINUX_EXTRA_POLICY_RHEL8 --param=RPM_OVS=$RPM_OVS --param=mh-NIC_DRIVER=$server_driver,$client_driver --wb "$fdp_release, $ovs_rpm_name, $compose, openvswitch/mcast_snoop, Client driver: $client_driver, Server driver: $server_driver"
	
popd


