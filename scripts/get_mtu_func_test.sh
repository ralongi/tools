get_current_link_cfg()
{
    ip a | grep -A4 $iface
    echo -e " \n"
	ip a | grep $intport; if [[ $? == 0 ]]; then ip a | grep -A4 $intport; fi
    echo -e " \n"
    ip r
    echo -e " \n"
    ip -6 r
    echo -e " \n"
    ovs-vsctl show
    echo -e " \n"
	if [ $use_vm == yes ]; then
		    ip a | grep -A4 $vnet
    		echo -e " \n"
		    vmsh run_cmd $vm "ip a" > ip_a.tmp
			echo "Configuration on VM $iface_vm: "
    		echo -e " \n"
    		grep -A4 $iface_vm ip_a.tmp
			echo -e " \n"
	fi
}





get_mtu()
{
	if [ $use_vm == yes ]; then
		for i in [$iface $vnet]; do
			act_mtu_host=$(ip l l | grep $i | grep mtu | awk '{ print $5 }')
			echo "The current MTU setting for $i is: $act_mtu_host"
		done
		
		vmsh run_cmd $vm "ip l l" > mtu.tmp
    	mtu_vm=$(grep $iface_vm mtu.tmp | awk '{ print $5 }')
    	echo "The current MTU setting for $iface_vm on VM $vm is: $mtu_vm"
		rm -f mtu.tmp

	else
		for i in [$iface $intport]; do
			act_mtu_host=$(ip l l | grep $i | grep mtu | awk '{ print $5 }')
			echo "The current MTU setting for $i is: $act_mtu"
		done
	fi
}



get_link_info()
{
	if [ $use_vm == yes ]; then
		for i in [$iface $vnet $intport]; do
			act_mtu_host=$(ip l l | grep $i | grep mtu | awk '{ print $5 }')
			echo "The current MTU setting for $i is: $act_mtu_host"
		done
		
		vmsh run_cmd $vm "ip l l" > mtu.tmp
    	mtu_vm=$(grep $iface_vm mtu.tmp | awk '{ print $5 }')
    	echo "The current MTU setting for $iface_vm on VM $vm is: $mtu_vm"
		rm -f mtu.tmp

	else
		for i in [$iface $intport]; do
			act_mtu_host=$(ip l l | grep $i | grep mtu | awk '{ print $5 }')
			echo "The current MTU setting for $i is: $act_mtu"
		done
	fi
}


