# To be run on Client

OVSBR=ovsbr0
IPADDR_BASE=192.168.0

ovs-vsctl --if-exists del-br $OVSBR
ovs-vsctl add-br $OVSBR

for i in {0..99}
do

        NS=netns"$i"
        # create veth pair
        EVEN=`expr 2 \* $i`
        ODD=`expr 2 \* $i + 1`
        echo $EVEN $ODD
        VETH_EVEN=veth"$EVEN"
        VETH_ODD=veth"$ODD"

        ip netns add $NS
        ip link add $VETH_EVEN netns $NS type veth peer name $VETH_ODD
        ip link set $VETH_ODD up
        ovs-vsctl add-port $OVSBR $VETH_ODD
        ADDR=`expr $ODD + 1`
        ip netns exec $NS ip addr add $IPADDR_BASE."$ADDR"/24 dev $VETH_EVEN
        ip netns exec $NS ip link set lo up
        ip netns exec $NS ip link set $VETH_EVEN up
        ip netns exec $NS ip a
	#netperf -L $IPADDR_BASE."$ADDR" -H $IPADDR_BASE.$(($ADDR + 100)) -t TCP_STREAM -l 600
done

~                                                                                                   
~                                                                                                   
~                                                                                                   
~                                                                                                   
~                                                                                                   
~                                                                                                   
~                                                                                                   
~                                                                                                   
~                                                                                                   
~                                                                                                   
~                                                                                                   
~                                                                                                   
~                                                                                                   
~                                                                                                   
~                                                                                                   
~                                                                                                   
~                                                                                                   
~                                                                                                   
~                                                                                                   
~                                                                                                   
~                                                                                                   
"config-ovs-with-netns.sh" 28L, 608C

