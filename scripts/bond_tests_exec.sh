#!/bin/bash

dbg_flag=${dbg_flag:-"set +x"}
$dbg_flag
arch=${arch:-"x86_64"}
job_dbg_flag=${job_dbg_flag:-"set +x"}

machine_pool=${machine_pool:-'"netqe11.knqe.lab.eng.bos.redhat.com,netqe44.knqe.lab.eng.bos.redhat.com,netqe21.knqe.lab.eng.bos.redhat.com"'}

display_usage()
{
	echo "Usage: $0 <COMPOSE ID> <Tier or test list> [Driver]"
	echo "Example: $0 RHEL-7.5-20171130.0 1 bnxt_en"
	echo "Example: $0 RHEL-7.5-20171130.0 setup_bond bnxt_en"
	echo "Note: Driver is optional"
}

if [[ $# -lt 2 ]]; then display_usage; exit; fi

compose=$1
tier=$2
if [[ $# -eq 3 ]]; then driver=$3; fi
if [[ -z $driver ]]; then driver="any"; fi

if [[ $tier == "0" ]]; then
	test_list="sanity_check setup_bond module_load_unload"
elif [[ $tier == "1" ]]; then
	test_list="sanity_check setup_bond module_load_unload parameters modes"
elif [[ $tier == "2" ]]; then
	test_list="sanity_check setup_bond module_load_unload parameters modes failover"
elif [[ $tier == "3" ]]; then
	test_list="sanity_check setup_bond module_load_unload parameters modes failover Regression"
elif [[ $tier == "4" ]]; then
	test_list="failover Regression"
elif [[ $tier == "regression" ]] || [[ $tier == "Regression" ]]; then
	test_list="Regression"
else
	test_list=$2
fi

echo "Running Tier $tier Bonding tests on arch $arch using compose $compose..."
echo "Test list: $test_list"
pushd /home/ralongi/git/kernel/networking/bonding

for test in $test_list; do
	subtest=$(lstest $test | awk '{print $2}' | tr -d ':')
	echo "Parent test name: $test"
	echo "Subtest name: $subtest"
	echo "-------------------------------------"
	if [[ "$compose" = *"RHEL-8"* ]]; then
		variant="BaseOS"
	else
		variant="Server"
	fi
	
	if [[ $arch != "x86_64" ]]; then
		lstest $test/ | runtest $compose --variant=$variant --arch=$arch --param=NAY=yes --param=NIC_DRIVER=$driver --param=dbg_flag="$job_dbg_flag" --wb "Tier $tier Bonding test run, Compose: $compose, Arch: $arch, Test: $subtest, Driver Specified: $driver"
	else
		lstest $test/ | runtest $compose --variant=$variant --ormachine=$machine_pool --param=NAY=yes --param=NIC_DRIVER=$driver --param=dbg_flag="$job_dbg_flag" --wb "Tier $tier Bonding test run, Compose: $compose, Arch: $arch, Test: $subtest, Driver Specified: $driver"
	fi
done

popd
