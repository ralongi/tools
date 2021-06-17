test_list=${test_list:-""}
machine_pool=${machine_pool:-"netqe11.knqe.lab.eng.bos.redhat.com,netqe12.knqe.lab.eng.bos.redhat.com,netqe20.knqe.lab.eng.bos.redhat.com,netqe21.knqe.lab.eng.bos.redhat.com"}
subtest=$(lstest $test | awk '{print $2}' | tr -d ':')
test_parent=$(pwd | awk -F "/" '{print $NF}')

for test in $test_list; do
	subtest=$(lstest $test | awk '{print $2}' | tr -d ':')
	lstest $test/ | runtest $compose --variant=Server --ormachine=$machine_pool --param=NAY=yes --wb "Tier $tier $test_parent test run for 50G, Compose: $compose, Test: $subtest"
done


for test in $test_list; do
	subtest=$(lstest $test | awk '{print $2}' | tr -d ':')
	lstest $test/ | runtest $compose --variant=Server --ormachine=$machine_pool --param=NAY=yes --param=NIC_SPEED=50000 --netqe-nic-speed=50000 --wb "Tier $tier $test_parent test run for 50G, Compose: $compose, Test: $subtest"
done

