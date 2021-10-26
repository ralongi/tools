
pushd /home/ralongi/git/kernel/networking/openvswitch

dbg_flag=${dbg_flag:-"set +x"}
$dbg_flag
arch=${arch:-"x86_64"}
machine_pool=${machine_pool:-'"netqe12.knqe.lab.eng.bos.redhat.com"'}
starting_compose=${starting_compose:-""}
target_compose=${target_compose:-""}

common_param_list="--param=NAY=yes --param=lp_test_type=RHELOSP 

lstest upgrade_ovs/ | runtest $starting_compose --variant=Server --ormachine=$machine_pool --param=NAY=yes --wb "OVS kernel datapath upgrade test - $starting_compose to $target_compose with OVS for RHOSP 10, 11, 12 to latest available openvswitch package, Test: upgrade_ovs (SELinux: Enabled)"
