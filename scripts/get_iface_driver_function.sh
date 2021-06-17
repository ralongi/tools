get_iface_driver()
{
	local iface_list=$(ip l l | grep BROADCAST | awk -F ":" '{ print $2 }')
	local drivers=$(for i in $iface_list; do ethtool -i $i | grep driver | awk '{ print $2 }'; done)
	local result_file="iface_driver_list"

	count=0
	for i in $iface_list; do
		count=$(( $count + 1 ))
		echo "$count Interface: "$i
	done

	echo -e " \n"

	count=0
	for i in $drivers; do
		count=$(( $count + 1 ))

		if [ $i == "bnx2x" ]; then
			echo "$count Driver: "$i "(Broadcom 10Gbe)"
		elif [ $i == "cxgb4" ]; then
			echo "$count Driver: "$i "(Chelsio 10Gbe)"
		elif [ $i == "ixgbe" ]; then
			echo "$count Driver: "$i "(Intel 10Gbe)"
		elif [ $i == "igb" ]; then
			echo "$count Driver: "$i "(Intel 1Gbe)"
		elif [ $i == "tg3" ]; then
			echo "$count Driver: "$i "(Broadcom 1Gbe)"
		elif [ $i == "mlx4_en" ]; then
			echo "$count Driver: "$i "(Mellanox 10Gbe/40Gbe)"
		else echo "$count Driver: "$i
		fi
	done
}

