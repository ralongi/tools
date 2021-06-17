# OVS runtest.sh functions

# functions to start netperf
netperf_start()
{
	pgrep netserver
	if [[ $? != 0 ]]; then
		pkill netserver; sleep 2; netserver
	else
		echo "netserver is running."
	fi
}

vm_netperf_start()
{
	vmsh run_cmd $vm "pgrep netserver" > pgrep_nserv.txt
	dos2unix -f pgrep_nserv.txt
	r=$(grep -A1 'echo $?' pgrep_nserv.txt | awk '{ getline; print }')	
	if [[ $r != 0 ]]; then
		vmsh run_cmd $vm "pkill netserver; sleep 2; netserver"
		rm -f pgrep_nserv.txt
	else
        echo "netserver is running."
		rm -f pgrep_nserv.txt
	fi
}

# function to obtain interface being used on VM and set it to $iface_vm
get_iface_vm()
{
    vmsh run_cmd $vm "ip l l" > ip_a.tmp
    iface_vm=$(grep BROADCAST ip_a.tmp | awk '{ print $2 }'| awk -F ":" '{ print $1 }')
    echo "The interface on the VM is: $iface_vm"
}

# function to update kernel on the VM
update_kernel_vm()
{
    vmsh run_cmd $vm "uname -r" > vm_k_ver.txt
    dos2unix -f vm_k_ver.txt
	host_k_ver=$(uname -r)
	vm_k_ver=$(awk '/uname -r/{getline; print}' vm_k_ver.txt)
    rm -f vm_k_ver.txt
        
	if [[ "$host_k_ver" == "$vm_k_ver" ]]; then
        echo "Kernel versions match."
        return 0
    else
    	local intport_ip4_tmp=$(echo $ip4addr_vm | awk -F "." '{ print $1"."$2"."$3"."$4+20 }')
        local host_kernel_rpm=$(uname -r | awk '{
    		split($0,v,"-");
    		s=v[2];
    		do {
    			i=index(s,".");
    			s=substr(s, i+1)
    		} while(i > 0)
    		sub("."s,"",v[2])
                    print "kernel-"v[1]"-"v[2]"."s".rpm"}')
        echo $host_kernel_rpm > host_kernel_rpm.tmp
        local v1=$(awk -F "-" '{ print $2 }' host_kernel_rpm.tmp)
        local v2=$(awk -F "-" '{ print $3 }' host_kernel_rpm.tmp | awk -F "." '{ print $1"."$2 }')
        local p=$(awk -F "-" '{ print $3 }' host_kernel_rpm.tmp | awk -F "." '{ print $3 }')
	
        ip a | grep $intport | grep "$intport_ip4_tmp"
        if [[ $? != 0 ]]; then
            ip addr add $intport_ip4_tmp/24 dev $intport
        fi
        cd /var/www/html; rm -f *rpm*
	    wget -nv http://download.eng.bos.redhat.com/brewroot/packages/kernel/$v1/$v2/$p/$host_kernel_rpm
    fi

	vmsh run_cmd $vm "rpm -ivh --nodeps --force http://"$intport_ip4_tmp"/$host_kernel_rpm"
	virsh reboot $vm

    # flush temporary intport IP address
    ip a | grep $intport | grep "$intport_ip4_tmp"
    if [[ $? == 0 ]]; then
        ip addr del $intport_ip4_tmp/24 dev $intport
    fi

	sleep 90
}

get_current_link_cfg()
{
    ip a | grep -A4 $iface
    echo -e
	ip a | grep $intport; if [[ $? == 0 ]]; then ip a | grep -A4 $intport; fi
    echo -e
    ip r
    echo -e
    ip -6 r
    echo -e
    ovs-vsctl show
    echo -e
	if [ $use_vm == yes ]; then
		    ip a | grep -A4 $vnet
    		echo -e
		    vmsh run_cmd $vm "ip a" > ip_a.tmp
			echo "Configuration on VM $iface_vm: "
    		echo -e
    		grep -A4 $iface_vm ip_a.tmp
			echo -e
	fi
}

get_nic_driver_info()
{
    echo "NIC driver information for $iface: "
    echo -e
    ethtool -i $iface
    echo -e
    ethtool $iface
    echo -e
    ethtool -k $iface
    echo -e
}

vxlan_offload_check_enable()
{
    local tnl_offload=$(ethtool -k $iface | grep tx-udp_tnl-segmentation | awk '{ print $2 }')
    if [[ $rhel_version -ge 7 && $tnl_offload == off ]]; then
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

# functions to configure static/persistent IP addresses
set_ipaddr_rhel6()
{
    #The method below calls the "cfg_static_ip" function from kernel/networking/impairment/networking_common.sh and passes the necessary arguments
    cfg_static_ip $ip4addr $ip6addr $iface $mtu
    sleep 5
    ip a | grep -C4 $iface; ip r; ip -6 r
}

set_ipaddr_rhel7()
{
    #The method below calls functions from kernel/networking/impairment/networking_common.sh and uses nmcli to configure IP addresses
    nmcli con add con-name $con_name ifname $iface type ethernet ip4 $ip4addr/24 ip6 $ip6addr/64
    nmcli con mod $con_name 802-3-ethernet.mtu $mtu
    nmcli con up $con_name
    sleep 5
    ip a | grep -C4 $iface; ip r; ip -6 r
}

# function to set non-persistent IP addresses for OVS NIC tests
set_ipaddr_nic()
{  
    local use_vm=${use_vm:-"no"}

    ip link set dev $iface mtu $mtu
    ip link set dev $iface up
    ip addr add $ip4addr/24 dev $iface
    ip -6 addr add $ip6addr/64 dev $iface
    sleep 10
    get_current_link_cfg
}

# functions to config OVS, set non-persistent IP addresses for OVS tests
ovs_nic_cfg()
{
    local use_vm=${use_vm:-"no"}

    ovs-vsctl --if-exists del-br $ovsbr
    ovs-vsctl add-br $ovsbr
    ovs-vsctl add-port $ovsbr $iface
    if [ $use_vm == yes ]; then
        local vm_status=$(virsh list --all | grep $vm | awk '{ print $3 }')
        echo "The current status of VM $vm is: $vm_status"
        if [[ $vm_status != running ]]; then
            # start vm and wait for it to boot up
            virsh start $vm
            sleep 90
        fi

        # set MTU on VM
        vmsh run_cmd $vm "ip link set dev $iface_vm mtu $mtu"

        # start netserver (if necessary)
        vm_netperf_start

        # add vnet to ovsbr and set vnet mtu
        ovs-vsctl add-port $ovsbr $vnet
        #ip link set dev $vnet mtu $mtu
    fi
    ip link set dev $iface mtu $mtu
    ip link set dev $ovsbr up
    ip link set dev $iface up
    ip addr add $ip4addr/24 dev $ovsbr
    ip -6 addr add $ip6addr/64 dev $ovsbr
    sleep 10
    get_current_link_cfg
}

ovs_cfg()
{
    local use_vm=${use_vm:-"no"}

    ovs-vsctl --if-exists del-br $ovsbr
    ovs-vsctl add-br $ovsbr
    ovs-vsctl add-port $ovsbr $intport -- set interface $intport type=internal
    ovs-vsctl add-port $ovsbr $iface
    if [ $use_vm == yes ]; then
        local vm_status=$(virsh list --all | grep $vm | awk '{ print $3 }')
        echo "The current status of VM $vm is: $vm_status"
        if [[ $vm_status != running ]]; then
            # start vm and wait for it to boot up
            virsh start $vm
            sleep 90
        fi

        # set MTU on VM
        vmsh run_cmd $vm "ip link set dev $iface_vm mtu $mtu"

        # start netserver (if necessary)
        vm_netperf_start

        # remove $intport since it's not needed for VM to VM tests, add vnet to ovsbr and set vnet vlan tag and mtu
        ovs-vsctl del-port $ovsbr $intport
        ovs-vsctl add-port $ovsbr $vnet        
        #ip link set dev $vnet mtu $mtu
    fi
    ip link set dev $iface mtu $mtu
    ip link set dev $intport mtu $mtu || true
    ip link set dev $ovsbr up
    ip link set dev $iface up
    ip link set dev $intport up
    ip addr add $intport_ip4/24 dev $intport
    ip -6 addr add $intport_ip6/64 dev $intport
    sleep 10
    get_current_link_cfg
}

ovs_vlan_cfg()
{
    local use_vm=${use_vm:-"no"}

    ovs-vsctl --if-exists del-br $ovsbr
    ovs-vsctl add-br $ovsbr
    ovs-vsctl add-port $ovsbr $intport -- set interface $intport type=internal
    ovs-vsctl set port $intport tag=$tag
    ovs-vsctl add-port $ovsbr $iface
    if [ $use_vm == yes ]; then
        local vm_status=$(virsh list --all | grep $vm | awk '{ print $3 }')
        echo "The current status of VM $vm is: $vm_status"
        if [[ $vm_status != running ]]; then
            # start vm and wait for it to boot up
            virsh start $vm
            sleep 90
        fi

        # set MTU on VM
        vmsh run_cmd $vm "ip link set dev $iface_vm mtu $mtu"

        # start netserver (if necessary)
        vm_netperf_start

        # remove $intport since it's not needed for VM to VM tests, add vnet to ovsbr and set vnet vlan tag and mtu
        ovs-vsctl del-port $ovsbr $intport
        ovs-vsctl add-port $ovsbr $vnet
        ovs-vsctl set port $vnet tag=$tag    
        #ip link set dev $vnet mtu $mtu
    fi
    ip link set dev $iface mtu $mtu
    ip link set dev $intport mtu $mtu || true
    ip link set dev $ovsbr up
    ip link set dev $iface up
    ip link set dev $intport up
    ip addr add $intport_ip4/24 dev $intport
    ip -6 addr add $intport_ip6/64 dev $intport
    sleep 10
    get_current_link_cfg
}

ovs_vxlan_cfg()
{
    local use_vm=${use_vm:-"no"}
    local use_vxlan="yes"

    if i_am_client; then
        sleep 60
        ping -c3 $ip4addr_peer
    fi   

    ovs-vsctl --if-exists del-br $ovsbr
    ovs-vsctl add-br $ovsbr
    ip link set dev $ovsbr up
    ovs-vsctl add-port $ovsbr $vxlan_tun -- set interface $vxlan_tun type=vxlan options:remote_ip=$ip4addr_peer
    ovs-vsctl add-port $ovsbr $intport -- set interface $intport type=internal
    if [ $use_vm == yes ]; then
        local vm_status=$(virsh list --all | grep $vm | awk '{ print $3 }')
        echo "The current status of VM $vm is: $vm_status"
        if [[ $vm_status != running ]]; then
            # start vm and wait for it to boot up
            virsh start $vm
            sleep 90
        fi

        # set MTU on VM
        vmsh run_cmd $vm "ip link set dev $iface_vm mtu $vxlan_mtu"

        # start netserver (if necessary)
        vm_netperf_start
    
        # remove $intport since it's not needed for VM to VM tests, add vnet to ovsbr and set vnet mtu
        ovs-vsctl del-port $ovsbr $intport
        ovs-vsctl add-port $ovsbr $vnet
        #ip link set dev $vnet mtu $mtu
    fi
    ip addr add $ip4addr/24 dev $iface
    ip link set dev $iface mtu $mtu
    ip link set dev $intport mtu $vxlan_mtu || true
    ip link set dev $iface up
    ip link set dev $intport up
    ip addr add $intport_ip4/24 dev $intport
    ip -6 addr add $intport_ip6/64 dev $intport
    sleep 10
    get_current_link_cfg
    dmesg | grep -i vxlan
    sleep 10
    vxlan_offload_check_enable
    sleep 10
    dmesg | grep -i vxlan
}
    
ovs_vxlan_vlan_cfg()
{
    local use_vm=${use_vm:-"no"}
    local use_vxlan_vlan="yes"

    if i_am_client; then
        sleep 60
        ping -c3 $ip4addr_peer
    fi

    ovs-vsctl --if-exists del-br $ovsbr
    ovs-vsctl add-br $ovsbr
    ip link set dev $ovsbr up
    ovs-vsctl add-port $ovsbr $vxlan_tun -- set interface $vxlan_tun type=vxlan options:remote_ip=$ip4addr_peer
    ovs-vsctl add-port $ovsbr $intport -- set interface $intport type=internal
    ovs-vsctl set port $intport tag=$tag
    if [ $use_vm == yes ]; then
        local vm_status=$(virsh list --all | grep $vm | awk '{ print $3 }')
        echo "The current status of VM $vm is: $vm_status"
        if [[ $vm_status != running ]]; then
            # start vm and wait for it to boot up
            virsh start $vm
            sleep 90
        fi   
        # set MTU on VM
        vmsh run_cmd $vm "ip link set dev $iface_vm mtu $vxlan_vlan_mtu"

        # start netserver (if necessary)
        vm_netperf_start
    
        # remove $intport since it's not needed for VM to VM tests, add vnet to ovsbr and set vnet vlan tag and mtu
        ovs-vsctl del-port $ovsbr $intport
        ovs-vsctl add-port $ovsbr $vnet
        ovs-vsctl set port $vnet tag=$tag
        #ip link set dev $vnet mtu $mtu
    fi
    ip link set dev $iface mtu $mtu
    ip link set dev $intport mtu $vxlan_vlan_mtu || true
    ip link set dev $iface up
    ip link set dev $intport up
    ip addr add $ip4addr/24 dev $iface
    ip addr add $intport_ip4/24 dev $intport
    ip -6 addr add $intport_ip6/64 dev $intport
    sleep 10
    get_current_link_cfg
    dmesg | grep -i vxlan
    sleep 10
    vxlan_offload_check_enable
    sleep 10
    dmesg | grep -i vxlan
}

ovs_gre_cfg()
{
    local use_vm=${use_vm:-"no"}
    local use_gre="yes"

    ovs-vsctl --if-exists del-br $ovsbr
    ovs-vsctl add-br $ovsbr
    ip link set dev $ovsbr up
    ovs-vsctl add-port $ovsbr $gre_tun -- set interface $gre_tun type=gre options:remote_ip=$ip4addr_peer
    ovs-vsctl add-port $ovsbr $intport -- set interface $intport type=internal
    if [ $use_vm == yes ]; then
        local vm_status=$(virsh list --all | grep $vm | awk '{ print $3 }')
        echo "The current status of VM $vm is: $vm_status"
        if [[ $vm_status != running ]]; then
            # start vm and wait for it to boot up
            virsh start $vm
            sleep 90
        fi

        # set MTU on VM
        vmsh run_cmd $vm "ip link set dev $iface_vm mtu $gre_mtu"

        # start netserver (if necessary)
        vm_netperf_start

        # remove $intport since it's not needed for VM to VM tests, add vnet to ovsbr and set vnet mtu
        ovs-vsctl del-port $ovsbr $intport
        ovs-vsctl add-port $ovsbr $vnet
        #ip link set dev $vnet mtu $mtu
    fi
    ip link set dev $iface mtu $mtu
    ip link set dev $intport mtu $gre_mtu  || true
    ip link set dev $iface up
    ip link set dev $intport up
    ip addr add $ip4addr/24 dev $iface
    ip addr add $intport_ip4/24 dev $intport
    ip -6 addr add $intport_ip6/64 dev $intport
    sleep 10
    get_current_link_cfg
    local tnl_offload=$(ethtool -k $iface | grep tx-udp_tnl-segmentation | awk '{ print $2 }')
    echo "tx-udp_tnl-segmentation is set to: $tnl_offload"
}
    
ovs_gre_vlan_cfg()
{
    local use_vm=${use_vm:-"no"}
    local use_gre_vlan="yes"

    ovs-vsctl add-br $ovsbr
    ip link set dev $ovsbr up
    ovs-vsctl add-port $ovsbr $gre_tun -- set interface $gre_tun type=gre options:remote_ip=$ip4addr_peer
    ovs-vsctl add-port $ovsbr $intport -- set interface $intport type=internal
    ovs-vsctl set port $intport tag=$tag
    if [ $use_vm == yes ]; then
        local vm_status=$(virsh list --all | grep $vm | awk '{ print $3 }')
        echo "The current status of VM $vm is: $vm_status"
        if [[ $vm_status != running ]]; then
            # start vm and wait for it to boot up
            virsh start $vm
            sleep 90
        fi

        # set MTU on VM
        vmsh run_cmd $vm "ip link set dev $iface_vm mtu $gre_vlan_mtu"

        # start netserver (if necessary)
        vm_netperf_start
 
        # remove $intport since it's not needed for VM to VM tests, add vnet to ovsbr and set vnet vlan tag and mtu
        ovs-vsctl del-port $ovsbr $intport
        ovs-vsctl add-port $ovsbr $vnet
        ovs-vsctl set port $vnet tag=$tag
        #ip link set dev $vnet mtu $mtu
    fi
    ip link set dev $iface mtu $mtu
    ip link set dev $intport mtu $gre_vlan_mtu || true
    ip link set dev $iface up
    ip link set dev $intport up
    ip addr add $ip4addr/24 dev $iface
    ip addr add $intport_ip4/24 dev $intport
    ip -6 addr add $intport_ip6/64 dev $intport
    sleep 10
    get_current_link_cfg
    local tnl_offload=$(ethtool -k $iface | grep tx-udp_tnl-segmentation | awk '{ print $2 }')
    echo "tx-udp_tnl-segmentation is set to: $tnl_offload"
}

# function to clean up entire environment before and after overall test run
cleanup_env()
{
	# echo "remove any bridge if exist"
	brctl show | sed -n 2~1p | awk '/^[[:alpha:]]/ { system("ip link set "$1" down; brctl delbr "$1) }'

	# echo "remove any ovs bridge if exist"
	ovs-vsctl list bridge | grep name | awk '{system("ovs-vsctl --if-exist del-br "$3)}'

	# echo "remove any vxlan if exist"
	ip -d link show | grep "\bvxlan\b" -B 2 | sed -n 1~3p | awk '{gsub(":",""); system ("ip link del "$2)}'

	# echo "remove any gre if exist"
	ip -d link show|grep "\bgretap\b" -B 2 | sed -n 1~3p | awk '($2 ~ /[[:alnum:]]+@[[:alnum:]]+/) {split($2,gre,"@"); system("ip link del "gre[1])}'

	# echo "remove any VM if exist"
	virsh list --all | sed -n 3~1p | awk '/[[:alpha:]]+/ { if ($3 == "running") { system("virsh shutdown "$2); sleep 2; system("virsh destroy "$2) }; system("virsh undefine --managed-save --snapshots-metadata --remove-all-storage "$2) }'
	# echo "remove any vnet definition if exist"
	virsh net-list --all | sed -n 3~1p | awk '/[[:alnum:]]+/ { system("virsh net-destroy "$1); sleep 2; system("virsh net-undefine "$1) }'

	#echo "remove any netns if exist"
	ip netns list | awk '{system("ip netns del "$1)}'

	#echo "delete the static connection via nmcli"
    nmcli con show | grep $con_name
    if [[ $? == 0 ]]; then nmcli con del $con_name; fi    
}

# function to cleanup environment between individual tests    
cleanup()
{
    ip address flush dev $iface
    ip link set dev $iface down
    ip link set dev $iface mtu 1500
    ovs-vsctl --if-exists del-br $ovsbr
    if [ $use_vm == yes ]; then
        ip link set dev $vnet mtu 1500
        vmsh run_cmd $vm "ip link set mtu 1500 dev $iface_vm"
    fi
    sleep 10
}    
    
#----------------------------------------------------------

# install necessary packages.  functions below are pulled from kernel/networking/impairment/install.sh
do_install()
{
    # epel repo
    epe_install

    # netperf
    netperf_install
    pkill netserver; sleep 2; netserver

    # sshpass
    sshpass_install

    # dos2unix
    yum -y install dos2unix

    # httpd
    httpd_install

    # ovs
    ovs_install

    #virtualization
    virt_install

    # install ip netns
    iproute2_install

    # brctl
    brctl_install

    # ipmitool
    ipmitool_install
}

#----------------------------------------------------------

# set up env for ovs tests

setup_env()
{
    # disable a particular NIC driver for a test if so desired.  this is blank by default unless specified in job xml file
    if [[ $iface_driver != $disabled_nic_driver ]]; then
        disable_nic_driver $disabled_nic_driver
    else
        echo "The NIC driver that you are trying to disable is the driver under test.  This is not allowed."
    fi

    # display NIC driver details
    #get_nic_driver_info

    # check for vxlan offload settings for NIC driver under test and attempt to enable it via driver reload if it's not currently enabled
    #vxlan_offload_check_enable

    # configure static IP addresses for the interface under test on the host
    if (($rhel_version <= 6)); then
        set_ipaddr_rhel6
    else
        set_ipaddr_rhel7
    fi

    # set up aliases for name resolution
    alias_cfg

    # stop security features
    iptables_stop_flush && setenforce 0

    # pull down netperf rpm for later scp to VMs
    timeout 120s bash -c "until ping -c3 pkgs.repoforge.org; do sleep 10; done"
    cd /home; rm -f *netperf*; wget $pkg_netperf

    # enable vxlan offload for mlx4_en driver
    if [[ $rhel_version -ge 7 && $iface_driver == "mlx4_en" ]]; then
        echo "$iface_driver will be set up to support VXLAN offload."
	echo "options mlx4_core log_num_mgm_entry_size=-1 debug_level=1" > /etc/modprobe.d/mlx4_core.conf
	rmmod mlx4_en mlx4_ib mlx4_core; sleep 5; modprobe mlx4_core
    cat /etc/modprobe.d/mlx4_core.conf
    fi

    # VM related setup
    # pull down vm image and xml files to be used to create VM
    rm -f /tmp/$vm_xml_file /var/lib/libvirt/images/$vm_image_name
    wget -nv -O /var/lib/libvirt/images/$vm_image_name $vm_image_location/$vm_image_name 
    wget -nv -O /tmp/$vm.xml $vm_image_location/$vm_xml_file
    sleep 10

    # create OVS bridge to support subsequent VM creation
    local intport_ip4_tmp=$(echo $ip4addr_vm | awk -F "." '{ print $1"."$2"."$3"."$4+20 }')
    ovs-vsctl --if-exists del-br $ovsbr
    ovs-vsctl add-br $ovsbr
    ovs-vsctl add-port $ovsbr $intport -- set interface $intport type=internal
    ovs-vsctl add-port $ovsbr $iface
    ip a | grep $intport | grep "$intport_ip4_tmp"
    if [[ $? != 0 ]]; then
        ip addr add $intport_ip4_tmp/24 dev $intport
    fi
    ip link set dev $intport up
    sleep 10; ip a | grep -A1 $intport; ip r    

    # define the vm using xml file downloaded and start the VM
    virsh define /tmp/$vm.xml
    virsh start $vm
    sleep 90

    # get interface to be used on vm, set it to $iface_vm
    get_iface_vm

    # set static IP addresses so they will persist across reboots
    vmsh run_cmd g1 "cat /etc/redhat-release" > vm_rhel.txt
    local vm_rhel_version=$(grep -A1 "redhat-release" vm_rhel.txt | grep "Red Hat" | cut -f1 -d. | sed 's/[^0-9]//g')
    local vm_con_name="static-$iface_vm"
    local ifcfg_file="ifcfg-$iface_vm"
    local vm_hwaddr=$(vmsh run_cmd g1 "ip l l" > link.txt; grep -A1 $iface_vm link.txt | awk '{getline; print $2}')

    if [[ $vm_rhel_version -ge 7 ]]; then
        local cmd=(
	    {setenforce 0}
        {iptables -F}
	    {ip6tables -F}
	    {nmcli con add con-name $vm_con_name ifname $iface_vm type ethernet ip4 $ip4addr_vm/24 ip6 $ip6addr_vm/64}
        {nmcli con mod $vm_con_name 802-3-ethernet.mtu $mtu}
	    {nmcli con up $vm_con_name}
        {sleep 5}
        {ip a}
        {ip r}
        {ip -6 r}
	    {pkill netserver\; sleep 2\; netserver}
        )
    else
        vmsh run_cmd $vm "ip link set dev $iface_vm up; ip addr flush dev $iface_vm; ip addr add $ip4addr_vm/24 dev $iface_vm; ip a; ip r"
        sleep 3
        vmsh run_cmd $vm "timeout 30s bash -c \"until ping -c3 $intport_ip4_tmp; do sleep 10; done\""
        rm -f /var/www/html/$ifcfg_file
        (
		    echo "DEVICE=$iface_vm"
		    echo "HWADDR=$vm_hwaddr"
		    echo "Type=Ethernet"
		    echo "ONBOOT=yes"
		    echo "NM_CONTROLLED=no"
		    echo "BOOTPROTO=none"
		    echo IPADDR=$ip4addr_vm
		    echo "NETMASK=255.255.255.0"
		    echo IPV6INIT=yes
		    echo IPV6ADDR=$ip6addr_vm/64
		    echo MTU=$mtu
	    )   > /var/www/html/$ifcfg_file
        local cmd=(
	    {setenforce 0}
	    {iptables -F}
	    {ip6tables -F}
	    {ip a}
	    {ip r}
        {ip -6 r}
	    {cd /etc/sysconfig/network-scripts}
        {rm -f $ifcfg_file}
        {wget -nv http://$intport_ip4_tmp/$ifcfg_file}
        {ifdown $iface_vm}
        {ifup $iface_vm}
        {sleep 5}
	    {ip a}
	    {ip r}
	    {ip -6 r}
	    {pkill netserver\; sleep 2\; netserver}
        )       
    fi   
    vmsh cmd_set $vm "${cmd[*]}"

    # update kernel on the VM if specified
    if [[ $up_knl_vm == yes ]]; then
        update_kernel_vm

        if [[ $vm_rhel_version -ge 7 ]]; then
            local cmd_k=(
            {setenforce 0}
            {iptables -F}
            {ip6tables -F}
            {ip a}
            {ip r}
            {ip -6 r}
	        {pkill netserver\; sleep 2\; netserver}
            )
        else
            local cmd_k=(
	        {setenforce 0}
	        {iptables -F}
	        {ip6tables -F}
            {ip a}
            {ip r}
            {ip -6 r}
	        {pkill netserver\; sleep 2\; netserver}
            )
        fi     
        vmsh cmd_set $vm "${cmd_k[*]}"
    fi

    # flush temporary intport IP address
    ip a | grep $intport | grep "$intport_ip4_tmp"
    if [[ $? == 0 ]]; then
        ip addr del $intport_ip4_tmp/24 dev $intport
    fi    
}

