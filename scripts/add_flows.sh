add_flows()
{
	target_bridge=$1
	if [[ $# -lt 1 ]]; then target_bridge=$ovsbr; fi
	flows_file="/tmp/flows.txt"
	flow_start=${flow_start:-"1"}
	flow_end=${flow_end:-"1000"}
	
	# delete any existing flows
	ovs-ofctl del-flows $target_bridge
	
	# write 1K flow rules to file
	rm -f $flows_file
	for i in $(seq $flow_start $flow_end); do
		echo "in_port=$i,idle_timeout=0,actions=output:$i" >> $flows_file
	done

    # add flows to $ovsbr and display them
    ovs-ofctl add-flows $target_bridge $flows_file
    ovs-ofctl dump-flows $target_bridge
}

