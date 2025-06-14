#!/bin/bash

# script to kick off OVS tests 

# First update and check in kernel/networking/openvswitch/common/package_list.sh
# Confirm that the target tests to be run are uncommented in /home/ralongi/inf_ralongi/Documents/ovs_testing/exec_my_ovs_tests_template.sh
# Confirm that the correct test is uncommented in /home/ralongi/inf_ralongi/Documents/ovs_testing/exec_topo.sh, exec_ovs_memory_leak_soak.sh

# requires user input for FDP relase, RHEL version and FDP stream
# example syntax: run_ovs_tests.sh 21e 8.4 2.13

dbg_flag=${dbg_flag:-"set -x"}
$dbg_flag

display_usage()
{
	echo "This script will kick off OVS tests based on parameters provided."
	echo "Usage: $0 <FDP Release> <RHEL Version> <FDP Stream>"
	echo "Example: $0 21e 8.4 2.13"
	echo "To use a specific compose (versus using latest), first execute 'export COMPOSE=<COMPOSE_ID>' in terminal window"
	exit 0
}

if [[ $# -lt 3 ]] || [[ $1 = "-h" ]] || [[ $1 = "--help" ]]	|| [[ $1 = "-?" ]]; then
	display_usage
fi

# Make sure local git is up to date
pushd /home/ralongi/git/my_fork/kernel/networking
git status | grep 'working tree clean' || git pull > /dev/null
popd

export FDP_RELEASE=${FDP_RELEASE:-"$1"}
export FDP_RELEASE=$(echo $FDP_RELEASE | tr '[:lower:]' '[:upper:]')

export RHEL_VER=${RHEL_VER:-"$2"}
export RHEL_VER_MAJOR=$(echo $RHEL_VER | awk -F "." '{print $1}')

export FDP_STREAM=${FDP_STREAM:-"$3"}
export FDP_STREAM2=$(echo $FDP_STREAM | tr -d '.')
if [[ $FDP_STREAM2 -gt 213 ]]; then
	YEAR=$(grep -i ovn ~/git/my_fork/kernel/networking/openvswitch/common/package_list.sh | grep $FDP_RELEASE | awk -F "_" '{print $3}' | grep -v 213 | tail -n1)
fi

get_starting_packages()
{
	$dbg_flag
    starting_stream=$(grep OVS$FDP_STREAM2 ~/git/my_fork/kernel/networking/openvswitch/common/package_list.sh | grep RHEL$RHEL_VER_MAJOR | egrep -vi 'python|tcpdump' | tail -n2 | head -n1 | awk -F "_" '{print $2}')
    
    export STARTING_RPM_OVS=$(grep "$starting_stream" ~/git/my_fork/kernel/networking/openvswitch/common/package_list.sh | grep OVS$FDP_STREAM2 | grep RHEL$RHEL_VER_MAJOR | egrep -vi 'python|tcpdump' | awk -F "=" '{print $2}')
    export STARTING_RPM_OVS_SELINUX_EXTRA_POLICY=$(grep "$starting_stream" ~/git/my_fork/kernel/networking/openvswitch/common/package_list.sh | grep -i selinux | grep RHEL$RHEL_VER_MAJOR | awk -F "=" '{print $NF}')

    echo "STARTING_RPM_OVS: $STARTING_RPM_OVS"
    echo "STARTING_RPM_OVS_SELINUX_EXTRA_POLICY: $STARTING_RPM_OVS_SELINUX_EXTRA_POLICY"
}

get_starting_packages

pushd /home/ralongi/github/tools/ovs_testing
/bin/cp -f exec_my_ovs_tests_template.sh exec_my_ovs_tests.sh
sed -i "s/FDP_RELEASE_VALUE/$FDP_RELEASE/g" exec_my_ovs_tests.sh
sed -i "s/RHEL_VER_VALUE/$RHEL_VER/g" exec_my_ovs_tests.sh
sed -i "s/FDP_STREAM_VALUE/$FDP_STREAM2/g" exec_my_ovs_tests.sh
sed -i "s/YEAR_VALUE/$YEAR/g" exec_my_ovs_tests.sh
sed -i "s/RHEL_VER_MAJOR_VALUE/$RHEL_VER_MAJOR/g" exec_my_ovs_tests.sh

# new code
if [[ -z $tests ]]; then
	tests=$(grep "^OVS-$FDP_STREAM-RHEL-$RHEL_VER_MAJOR-Tests" ~/github/tools/scripts/fdp_errata_list.txt | awk -F ":" '{print $NF}')
fi

for i in $tests; do
	if [[ $i == *"mcast_snoop"* ]]; then
		sed -i '/exec_mcast_snoop.sh/s/^#//g' exec_my_ovs_tests.sh
	elif [[ $i == *"ovs_qos"* ]]; then
		sed -i '/exec_ovs_qos.sh/s/^#//g' exec_my_ovs_tests.sh
	elif [[ $i == *"forward_bpdu"* ]]; then
		sed -i '/exec_forward_bpdu.sh/s/^#//g' exec_my_ovs_tests.sh
	elif [[ $i == *"of_rules"* ]]; then
		sed -i '/exec_of_rules.sh/s/^#//g' exec_my_ovs_tests.sh
	elif [[ $i == *"power_cycle_crash"* ]]; then
		sed -i '/exec_power_cycle_crash.sh/s/^#//g' exec_my_ovs_tests.sh
	elif [[ $i == *"ovs_upgrade"* ]]; then
		sed -i '/exec_ovs_upgrade.sh/s/^#//g' exec_my_ovs_tests.sh
	elif [[ $i == *"topo_ixgbe"* ]]; then
		if [[ $ovs_env ]]; then
			sed -i "/exec_topo.sh ixgbe ovs_env=$ovs_env/s/^#//g" exec_my_ovs_tests.sh
		else
			sed -i '/exec_topo.sh ixgbe/s/^#//g' exec_my_ovs_tests.sh
		fi
	elif [[ $i == *"topo_i40e"* ]]; then
		if [[ $ovs_env ]]; then
			sed -i "/exec_topo.sh i40e ovs_env=$ovs_env/s/^#//g" exec_my_ovs_tests.sh
		else
			sed -i '/exec_topo.sh i40e/s/^#//g' exec_my_ovs_tests.sh
		fi
	elif [[ $i == *"topo_e810"* ]] && [[ ! $(echo $i | grep bp) ]]; then
		if [[ $ovs_env ]]; then
			sed -i "/exec_topo.sh e810_ice ovs_env=$ovs_env/s/^#//g" exec_my_ovs_tests.sh
		else
			sed -i '/exec_topo.sh e810_ice/s/^#//g' exec_my_ovs_tests.sh
		fi
	elif [[ $i == *"topo_e830"* ]]; then
		if [[ $ovs_env ]]; then
			sed -i "/exec_topo.sh e830_ice ovs_env=$ovs_env/s/^#//g" exec_my_ovs_tests.sh
		else
			sed -i '/exec_topo.sh e830_ice/s/^#//g' exec_my_ovs_tests.sh
		fi
	elif [[ $i == *"topo_e825"* ]]; then
		if [[ $ovs_env ]]; then
			sed -i "/exec_topo.sh 825_ice ovs_env=$ovs_env/s/^#//g" exec_my_ovs_tests.sh
		else
			sed -i '/exec_topo.sh e825_ice/s/^#//g' exec_my_ovs_tests.sh
		fi
	elif [[ $i == *"topo_e810_ice_bp"* ]]; then
		if [[ $ovs_env ]]; then
			sed -i "/exec_topo.sh e810_ice_bp ovs_env=$ovs_env/s/^#//g" exec_my_ovs_tests.sh
		else
			sed -i '/exec_topo.sh e810_ice_bp/s/^#//g' exec_my_ovs_tests.sh
		fi
	elif [[ $i == *"topo_e823_ice_bp"* ]]; then
		if [[ $ovs_env ]]; then
			sed -i "/exec_topo.sh e823_ice_bp ovs_env=$ovs_env/s/^#//g" exec_my_ovs_tests.sh
		else
			sed -i '/exec_topo.sh e823_ice_bp/s/^#//g' exec_my_ovs_tests.sh
		fi
	elif [[ $i == *"topo_e823_ice_sfp"* ]]; then
		if [[ $ovs_env ]]; then
			sed -i "/exec_topo.sh e823_ice_sfp ovs_env=$ovs_env/s/^#//g" exec_my_ovs_tests.sh
		else
			sed -i '/exec_topo.sh e823_ice_sfp/s/^#//g' exec_my_ovs_tests.sh
		fi
	elif [[ $i == *"topo_mlx5_core_arm"* ]]; then
		if [[ $ovs_env ]]; then
			sed -i "/exec_topo.sh mlx5_core_arm ovs_env=$ovs_env/s/^#//g" exec_my_ovs_tests.sh
		else
			sed -i '/exec_topo.sh mlx5_core_arm/s/^#//g' exec_my_ovs_tests.sh
		fi
	elif [[ $i == *"topo_mlx5_core_cx5"* ]]; then
		if [[ $ovs_env ]]; then
			sed -i "/exec_topo.sh mlx5_core cx5 ovs_env=$ovs_env/s/^#//g" exec_my_ovs_tests.sh
		else
			sed -i '/exec_topo.sh mlx5_core cx5/s/^#//g' exec_my_ovs_tests.sh
		fi		
	elif [[ $i == *"topo_mlx5_core_cx6_dx"* ]]; then
	    if [[ $ovs_env ]]; then
			sed -i "/exec_topo.sh mlx5_core cx6 dx ovs_env=$ovs_env/s/^#//g" exec_my_ovs_tests.sh
		else
			sed -i '/exec_topo.sh mlx5_core cx6 dx/s/^#//g' exec_my_ovs_tests.sh
		fi
	elif [[ $i == *"topo_mlx5_core_cx6_lx"* ]]; then
	    if [[ $ovs_env ]]; then
			sed -i "/exec_topo.sh mlx5_core cx6 lx ovs_env=$ovs_env/s/^#//g" exec_my_ovs_tests.sh
		else
			sed -i '/exec_topo.sh mlx5_core cx6 lx/s/^#//g' exec_my_ovs_tests.sh
		fi
	elif [[ $i == *"topo_mlx5_core_cx7"* ]]; then
	    if [[ $ovs_env ]]; then
			sed -i "/exec_topo.sh mlx5_core cx7 ovs_env=$ovs_env/s/^#//g" exec_my_ovs_tests.sh
		else
			sed -i '/exec_topo.sh mlx5_core cx7/s/^#//g' exec_my_ovs_tests.sh
		fi
	elif [[ $i == *"topo_mlx5_core_bf2"* ]]; then
	    if [[ $ovs_env ]]; then
			sed -i "/exec_topo.sh mlx5_core bf2 ovs_env=$ovs_env/s/^#//g" exec_my_ovs_tests.sh
		else
			sed -i '/exec_topo.sh mlx5_core bf2/s/^#//g' exec_my_ovs_tests.sh
		fi
	elif [[ $i == *"topo_mlx5_core_bf3"* ]]; then
	    if [[ $ovs_env ]]; then
			sed -i "/exec_topo.sh mlx5_core bf3 ovs_env=$ovs_env/s/^#//g" exec_my_ovs_tests.sh
		else
			sed -i '/exec_topo.sh mlx5_core bf3/s/^#//g' exec_my_ovs_tests.sh
		fi
	elif [[ $i == *"topo_enic"* ]]; then
		if [[ $ovs_env ]]; then
			sed -i "/exec_topo.sh enic/s/^#//g ovs_env=$ovs_env/s/^#//g" exec_my_ovs_tests.sh
		else
			sed -i '/exec_topo.sh enic/s/^#//g' exec_my_ovs_tests.sh
		fi
	elif [[ $i == *"topo_qede"* ]]; then
	    if [[ $ovs_env ]]; then
			sed -i "/exec_topo.sh qede/s/^#//g ovs_env=$ovs_env/s/^#//g" exec_my_ovs_tests.sh
		else
			sed -i '/exec_topo.sh qede/s/^#//g' exec_my_ovs_tests.sh
		fi
	elif [[ $i == *"topo_bnxt_en"* ]]; then
	    if [[ $ovs_env ]]; then
			sed -i "/exec_topo.sh bnxt_en/s/^#//g ovs_env=$ovs_env/s/^#//g" exec_my_ovs_tests.sh
		else
			sed -i '/exec_topo.sh bnxt_en/s/^#//g' exec_my_ovs_tests.sh
		fi
	elif [[ $i == *"topo_ice_sts"* ]]; then
	    if [[ $ovs_env ]]; then
			sed -i "/exec_topo.sh sts/s/^#//g ovs_env=$ovs_env/s/^#//g" exec_my_ovs_tests.sh
		else
			sed -i '/exec_topo.sh sts/s/^#//g' exec_my_ovs_tests.sh
		fi
	elif [[ $i == *"topo_t4l"* ]]; then
	    if [[ $ovs_env ]]; then
			sed -i "/exec_topo.sh t4l/s/^#//g ovs_env=$ovs_env/s/^#//g" exec_my_ovs_tests.sh
		else
			sed -i '/exec_topo.sh t4l/s/^#//g' exec_my_ovs_tests.sh
		fi
	elif [[ $i == *"topo_empire"* ]]; then
	    if [[ $ovs_env ]]; then
			sed -i "/exec_topo.sh ice_empire/s/^#//g ovs_env=$ovs_env/s/^#//g" exec_my_ovs_tests.sh
		else
			sed -i '/exec_topo.sh ice_empire/s/^#//g' exec_my_ovs_tests.sh
		fi		
	elif [[ $i == *"topo_bmc57504"* ]]; then
	    if [[ $ovs_env ]]; then
			sed -i "/exec_topo.sh bnxt_en_bmc57504/s/^#//g ovs_env=$ovs_env/s/^#//g" exec_my_ovs_tests.sh
		else
			sed -i '/exec_topo.sh bnxt_en_bmc57504/s/^#//g' exec_my_ovs_tests.sh
		fi
	elif [[ $i == *"topo_6820c"* ]]; then
	    if [[ $ovs_env ]]; then
			sed -i "/exec_topo.sh 6820c/s/^#//g ovs_env=$ovs_env/s/^#//g" exec_my_ovs_tests.sh
		else
			sed -i '/exec_topo.sh 6820c/s/^#//g' exec_my_ovs_tests.sh
		fi	
	elif [[ $i == *"endurance_cx5"* ]]; then
		sed -i '/exec_endurance.sh cx5/s/^#//g' exec_my_ovs_tests.sh
	elif [[ $i == *"perf_ci_cx5"* ]]; then
		sed -i '/exec_perf_ci.sh cx5/s/^#//g' exec_my_ovs_tests.sh	
	elif [[ $i == *"endurance_cx6dx"* ]]; then
		sed -i '/exec_endurance.sh cx6dx/s/^#//g' exec_my_ovs_tests.sh
	elif [[ $i == *"perf_ci_cx6dx"* ]]; then
		sed -i '/exec_perf_ci.sh cx6dx/s/^#//g' exec_my_ovs_tests.sh
	elif [[ $i == *"endurance_cx6lx"* ]]; then
		sed -i '/exec_endurance.sh cx6lx/s/^#//g' exec_my_ovs_tests.sh
	elif [[ $i == *"perf_ci_cx6lx"* ]]; then
		sed -i '/exec_perf_ci.sh cx6lx/s/^#//g' exec_my_ovs_tests.sh
	elif [[ $i == *"endurance_bf2"* ]]; then
		sed -i '/exec_endurance.sh bf2/s/^#//g' exec_my_ovs_tests.sh
	elif [[ $i == *"perf_ci_bf2"* ]]; then
		sed -i '/exec_perf_ci.sh bf2/s/^#//g' exec_my_ovs_tests.sh
	elif [[ $i == *"sanity_check"* ]]; then
		sed -i '/exec_sanity_check.sh/s/^#//g' exec_my_ovs_tests.sh
	elif [[ $i == *"vm100"* ]]; then
		sed -i '/exec_vm100.sh/s/^#//g' exec_my_ovs_tests.sh
	elif [[ $i == *"ovs_memory_leak_soak_i40e"* ]]; then
		/bin/cp -f exec_ovs_memory_leak_soak_template.sh exec_ovs_memory_leak_soak.sh
		sed -i '/exec_ovs_memory_leak_soak.sh/s/^#//g' exec_my_ovs_tests.sh
		sed -i 's/dut:-""/dut:-"wsfd-advnetlab34.anl.eng.rdu2.dc.redhat.com"/g' exec_ovs_memory_leak_soak.sh
		sed -i 's/NIC_DRIVER:-""/NIC_DRIVER:-"i40e"/g' exec_ovs_memory_leak_soak.sh
	elif [[ $i == *"ovs_memory_leak_soak_mlx5_core"* ]]; then
		/bin/cp -f exec_ovs_memory_leak_soak_template.sh exec_ovs_memory_leak_soak.sh
		sed -i '/exec_ovs_memory_leak_soak.sh/s/^#//g' exec_my_ovs_tests.sh
		sed -i 's/dut:-""/dut:-"wsfd-advnetlab33.anl.eng.rdu2.dc.redhat.com"/g' exec_ovs_memory_leak_soak.sh
		sed -i 's/NIC_DRIVER:-""/NIC_DRIVER:-"mlx5_core"/g' exec_ovs_memory_leak_soak.sh
	elif [[ $i == *"ovs_memory_leak_soak_qede"* ]]; then
		/bin/cp -f exec_ovs_memory_leak_soak_template.sh exec_ovs_memory_leak_soak.sh
		sed -i '/exec_ovs_memory_leak_soak.sh/s/^#//g' exec_my_ovs_tests.sh
		sed -i 's/dut:-""/dut:-"hpe-netqe-syn480g10-01.knqe.lab.eng.bos.redhat.com"/g' exec_ovs_memory_leak_soak.sh
		sed -i 's/NIC_DRIVER:-""/NIC_DRIVER:-"qede"/g' exec_ovs_memory_leak_soak.sh
	fi
done

#echo ""
#if [[ $brew_target_flag == "off" ]] && [[ $zstream_compose ]]; then
#	echo "The test(s) will use the latest Z stream kernel included with $COMPOSE."
#else
#	echo "The test(s) will use the latest available brew kernel."
#fi
#echo ""

#while true; do
#    read -p   "Do you want to proceed using the kernel specified for the test(s)? " yn
#    case $yn in
#        [Yy]* ) break;;
#        [Nn]* ) exit;;
#        * ) echo "Please answer yes or no.";;
#        esac
#done


./exec_my_ovs_tests.sh

popd

echo "FDP_RELEASE: $FDP_RELEASE"
echo "RHEL_VER_MAJOR: $RHEL_VER_MAJOR"
echo "FDP_STREAM2: $FDP_STREAM2"
