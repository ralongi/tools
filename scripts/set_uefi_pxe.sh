#!/bin/bash

# Attempt to set uefi systems to PXE boot
# List of target uefi systems in file ~/uefi_pssh_hosts.txt, run ~/set_uefi_bootnext_pxi.sh on target systems

echo "Attempting to set PXE boot on uefi system(s)..."
if [[ $1 ]]; then
	ssh -O StrictHostKeyChecking=no $1 ~/set_uefi_bootnext_pxi.sh
else
	num_pssh_hosts=$(cat ~/uefi_pssh_hosts.txt | wc -l)
	timeout 10s bash -c "until pssh -O StrictHostKeyChecking=no -p $num_pssh_hosts -h ~/uefi_pssh_hosts.txt -t 0 -l root 'bash -s' < ~/set_uefi_bootnext_pxi.sh; do sleep 0; done"
fi

