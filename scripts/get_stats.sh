get_stats()
{
	dbg_flag=${dbg_flag:-"set +x"}
	$dbg_flag
	#trap read debug
	
	pushd () {
    command pushd "$@" > /dev/null
	}

	popd () {
		command popd "$@" > /dev/null
	}

	export pushd popd

	pushd ~
	
	rm -f stats.txt final_stats.txt
	
	echo "Please provide a list of interfaces to monitor:"
	read iface_list
	echo "Please hit <Enter> when you are ready to start capturing statistics:"
	read "response"
	echo "Capturing statistics for interfaces: $iface_list..."
	
	stats_list="tx_packets tx_bytes tx_dropped tx_errors rx_packets rx_bytes rx_dropped rx_errors"
	for stats in $stats_list; do
		for iface in $iface_list; do
			echo "start_""$stats"_$iface=$(cat /sys/class/net/$iface/statistics/$stats) >> stats.txt
		done
	done
	
	echo ""
	echo "Please hit <Enter> when you want to stop capturing statistics:"
	read "response"
	
	for stats in $stats_list; do
		for iface in $iface_list; do
			echo "end_""$stats"_$iface=$(cat /sys/class/net/$iface/statistics/$stats) >> stats.txt
		done
	done
	
	for iface in $iface_list; do
		for stats in $stats_list; do
			end_stats=$(grep $iface stats.txt | grep end_$stats | awk -F "=" '{print $NF}')
			start_stats=$(grep $iface stats.txt | grep start_$stats | awk -F "=" '{print $NF}')
			echo "total_""$stats""_"$iface=$((($end_stats - $start_stats))) >> final_stats.txt
		done
	done
	
	for iface in $iface_list; do
		echo ""
		echo "Statistics for $iface:"
		echo "============================="
		for stats in $stats_list; do
			total_stats=$(grep $iface final_stats.txt | grep total_$stats | awk -F "=" '{print $NF}')
			echo "Total $stats for $iface: $total_stats"
		done
		echo ""
		echo "============================="
	done
	rm -f stats.txt final_stats.txt
	popd || exit
}

get_stats_lite()
{
	dbg_flag=${dbg_flag:-"set +x"}
	$dbg_flag
	#trap read debug
	
	pushd () {
    command pushd "$@" > /dev/null
	}

	popd () {
		command popd "$@" > /dev/null
	}

	export pushd popd

	pushd ~
	
	rm -f stats.txt final_stats.txt
	
	echo "Please provide a list of interfaces to monitor:"
	read iface_list
	echo "Please hit <Enter> when you are ready to start capturing statistics:"
	read "response"
	echo "Capturing statistics for interfaces: $iface_list..."
	
	stats_list="tx_packets tx_bytes rx_packets rx_bytes"
	for stats in $stats_list; do
		for iface in $iface_list; do
			echo "start_""$stats"_$iface=$(cat /sys/class/net/$iface/statistics/$stats) >> stats.txt
		done
	done
	
	echo ""
	echo "Please hit <Enter> when you want to stop capturing statistics:"
	read "response"
	
	for stats in $stats_list; do
		for iface in $iface_list; do
			echo "end_""$stats"_$iface=$(cat /sys/class/net/$iface/statistics/$stats) >> stats.txt
		done
	done
	
	for iface in $iface_list; do
		for stats in $stats_list; do
			end_stats=$(grep $iface stats.txt | grep end_$stats | awk -F "=" '{print $NF}')
			start_stats=$(grep $iface stats.txt | grep start_$stats | awk -F "=" '{print $NF}')
			echo "total_""$stats""_"$iface=$((($end_stats - $start_stats))) >> final_stats.txt
		done
	done
	
	for iface in $iface_list; do
		echo ""
		echo "Statistics for $iface:"
		echo "============================="
		for stats in $stats_list; do
			total_stats=$(grep $iface final_stats.txt | grep total_$stats | awk -F "=" '{print $NF}')
			echo "Total $stats for $iface: $total_stats"
		done
		echo ""
		echo "============================="
	done
	rm -f stats.txt final_stats.txt
	popd || exit
}
