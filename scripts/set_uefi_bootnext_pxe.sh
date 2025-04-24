set_uefi_bootnext_pxe()
{
	$dbg_flag
	$DBG_FLAG
	local result=0
	echo "Attempting to set BootNext value to PXE Boot if this is a UEFI system..."
	if efibootmgr &>/dev/null; then
		echo "Settting UEFI BootNext value to PXE Boot..."
		echo ""
		bkr_ip_addr=$(ip r | grep default | awk '{print $(NF - 2)}')
		bkr_mac_addr=$(ip a | grep -B3 "$bkr_ip_addr" | grep ether | awk '{print $2}')
		pxe_boot_opt=$(efibootmgr | grep -i "$bkr_mac_addr" | head -1 | awk '{print $1}' | tr -d [Boot*])
		if [[ -z $pxe_boot_opt ]]; then
			pxe_boot_opt=$(efibootmgr | grep -iw NIC | head -1 | awk '{print $1}' | tr -d [Boot*])
		fi
		if [[ -z $pxe_boot_opt ]]; then
			echo "No PXE boot option available"
			return 1
		fi
		boot_current=$(efibootmgr | grep BootCurrent | awk '{print $NF}')
		efibootmgr -n "$pxe_boot_opt"
		if [[ $(efibootmgr | grep -i BootNext | awk '{print $NF}') == "$pxe_boot_opt" ]]; then
			echo "UEFI BootNext value was successfully set to the correct PXE boot interface"
		else
			echo "UEFI BootNext value was NOT set to the correct PXE boot interface"
			((result+=1))
		fi
	else
		echo "UEFI efibootmgr is not present so BootNext value cannot be set"
	fi
	return $result
}

