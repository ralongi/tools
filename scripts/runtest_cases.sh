#!/bin/bash

TESTDIR="/home/jhsiao/nic-ovs-tunnel-test"
SERVER=192.168.13.20
if [ $# -gt 0 ]; then SERVER=$1; fi

run_netperf(){
	#. runtest_netperf.sh	
	$TESTDIR/runtest_netperf.sh $*
}

runtest(){

DTYPE=$1
LINK=$2

# Setup test config
case "$DTYPE"
in

	nic) 
		SERVER_IP=192.168.3.20
                CLIENT_IP=192.168.3.10
                $TESTDIR/nic_ipaddr_config.sh $LINK $CLIENT_IP
                ssh root@10.16.45.101 \
                "$TESTDIR/nic_ipaddr_config.sh $LINK $SERVER_IP; " &
                wait
	;;

	ovs)
		SERVER_IP=192.168.13.20
		CLIENT_IP=192.168.13.10
		ssh root@10.16.45.101 \
	"$TESTDIR/ovs_int_config.sh $LINK $SERVER_IP;" & 
	$TESTDIR/ovs_int_config.sh $LINK $CLIENT_IP
	wait
	;;

	vxlan)
		ssh root@10.16.45.101 \
		"$TESTDIR/ovs_tun_config.sh $DTYPE $LINK;" &
		$TESTDIR/ovs_tun_config.sh $DTYPE $LINK
		wait
	;;
	gre) 
		ssh root@10.16.45.101 \
		"$TESTDIR/ovs_tun_config.sh $DTYPE $LINK;" &
		$TESTDIR/ovs_tun_config.sh $DTYPE $LINK
		wait
	;;

esac

LOG_TYPE="$LINK"_"$DTYPE"
ping -c 10 -i 0.2  $SERVER && run_netperf $SERVER 10 30 $LOG_TYPE
#ping -c 10 -i 0.2  $SERVER && run_netperf $SERVER 1 1 $LOG_TYPE

# remote clean up
ssh root@10.16.45.101 "$TESTDIR/cleanup.sh $LINK;" &

# local clean up
$TESTDIR/cleanup.sh $LINK

wait
echo Sleeping 5 seconds
sleep 5
}

#main

echo ""
echo ""

# NIC to NIC
LINKTYPE=""
SERVER=192.168.3.20
for link in p3p1 p2p1 p6p1 p1p1 em4
do
	echo Starting runtest nic $link
	runtest nic $link
done

# {ovs, valxn, gre} x {bnx2x, ixgbe, igb, tg3}
SERVER=192.168.13.20
for link in p3p1 p2p1 p6p1 p1p1 em4
do
	for datapath_type in ovs vxlan gre
	do
		echo Starting runtest $datapath_type $link 
		runtest $datapath_type $link 
	done
done
