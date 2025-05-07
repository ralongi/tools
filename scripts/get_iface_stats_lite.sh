get_iface_stats_lite()
{
	iface=$1
	sleep_time=${sleep_time:-"3"}
	suppress_stats_output=${suppress_stats_output:-"no"}
	
	start_tx_packets=$(cat /sys/class/net/$iface/statistics/tx_packets)	
	start_rx_packets=$(cat /sys/class/net/$iface/statistics/rx_packets)	
	sleep $sleep_time
	end_tx_packets=$(cat /sys/class/net/$iface/statistics/tx_packets)
	end_rx_packets=$(cat /sys/class/net/$iface/statistics/rx_packets)

	total_tx_packets=$((($end_tx_packets - $start_tx_packets)))
	total_rx_packets=$((($end_rx_packets - $start_rx_packets)))
	echo "TX: $total_tx_packets packets observed on interface $iface."
	echo "RX: $total_rx_packets packets observed on interface $iface."
	
	if [[ $suppress_stats_output != "yes" ]]; then
		if [[ $total_tx_packets -le 0 ]]; then
			echo "TX traffic was NOT observed on interface $iface."
			echo "This may be expected if traffic is unidirectional.  Investigate further."
		else
			echo "TX traffic ($total_tx_packets packets) was observed on interface $iface."
		fi
		
		if [[ $total_rx_packets -le 0 ]]; then
			echo "RX traffic was NOT observed on interface $iface."
			echo "This may be expected if traffic is unidirectional.  Investigate further."
		else
			echo "RX traffic ($total_rx_packets packets) was observed on interface $iface."
		fi
	fi
}
