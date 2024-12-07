#!/bin/bash

set -x
if [[ -z $COMPOSE ]]; then COMPOSE=$1; fi
dut=${dut:-"wsfd-advnetlab33.anl.eng.rdu2.dc.redhat.com"}
product="cpe:/o:redhat:enterprise_linux"
retention_tag="active+1"

# ebpf_xdp/xdp_selftests

pushd ~/temp

lstest ~/git/my_fork/kernel/networking/ebpf_xdp/xdp_selftests | runtest --fetch-url kernel@https://gitlab.cee.redhat.com/kernel-qe/kernel/-/archive/master/kernel-master.tar.bz2 $COMPOSE --product=$product --retention-tag=$retention_tag --arch=x86_64 --topo=singleHost --systype=machine --machine=$dut $(echo "$zstream_repo_list") $(echo "$cmds") $(echo "$brew_build_cmd") --wb "(DUT: $dut), XDP Tools selftests, $COMPOSE, networking/ebpf_xdp/xdp_selftests $special_info" --append-task="/kernel/networking/openvswitch/crash_check {dbg_flag=set -x}"

popd 2>/dev/null
