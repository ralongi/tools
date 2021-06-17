# possible update to function that takes the driver name into consideration:

vxlan_offload_check_enable()
{
    local tnl_offload=$(ethtool -k $iface | grep tx-udp_tnl-segmentation | awk '{ print $2 }')
    if [[ $rhel_version -ge 7 && $tnl_offload == off && $driver == i40e || $driver == bnx2x || $driver == mlx4_en || $driver == be2net ]]; then
        #echo "THERE IS A PROBLEM WITH THE $driver VXLAN OFFLOAD SETTING!  IT IS NOT ENABLED!  RELOADING $driver DRIVER TO ATTEMPT TO ENABLE VXLAN OFFLOAD..."
        #rmmod ocrdma || true
        #rmmod $iface_driver; sleep 3; modprobe $iface_driver; sleep 3
        #ip link set dev $iface up
        #echo "The $driver driver has been reloaded.  tx-udp_tnl-segmentation is now set to: $tnl_offload"
        echo "THERE IS A PROBLEM WITH THE $iface_driver VXLAN OFFLOAD SETTING!  IT IS NOT ENABLED!  ATTEMPTING TO ENABLE VXLAN OFFLOAD on $iface USING ETHTOOL..."
        ethtool -K $iface tx-udp_tnl-segmentation on || true
        sleep 3
        echo "The ethtool command was executed on $iface in an attempt to enable vxlan offload.  tx-udp_tnl-segmentation is now set to: $tnl_offload"
    else 
        echo "tx-udp_tnl-segmentation is set to: $tnl_offload"
    fi
}

