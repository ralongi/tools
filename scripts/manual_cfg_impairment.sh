#!/bin/bash
# vim: dict=/usr/share/beakerlib/dictionary.vim cpt=.,w,b,u,t,i,k sts=4 sw=4 et
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   runtest.sh of /kernel/networking/impairment/tests/no_impairments
#   Author: Rick Alongi <ralongi@redhat.com>
#
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   Copyright (c) 2015 Red Hat, Inc.
#
#   This copyrighted material is made available to anyone wishing
#   to use, modify, copy, or redistribute it subject to the terms
#   and conditions of the GNU General Public License version 2.
#
#   This program is distributed in the hope that it will be
#   useful, but WITHOUT ANY WARRANTY; without even the implied
#   warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
#   PURPOSE. See the GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public
#   License along with this program; if not, write to the Free
#   Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
#   Boston, MA 02110-1301, USA.
#
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
dbg_flag=${dbg_flag:-"set -x"}
$dbg_flag

host=$(hostname)

CLIENTS="impairment1.knqe.lab.eng.bos.redhat.com"
SERVERS="impairment2.knqe.lab.eng.bos.redhat.com"

# variables
PACKAGE="kernel"

# rhel version
rhel_version=$(cut -f1 -d. /etc/redhat-release | sed 's/[^0-9]//g')

# install wget in case it's missing
yum -y install wget

# install beaker-client.repo
wget -O /etc/yum.repos.d/beaker-client.repo http://download.lab.bos.redhat.com/beakerrepos/beaker-client-RedHatEnterpriseLinux.repo

# install beaker related packages
yum -y install rhts-test-env beakerlib rhts-devel rhts-python beakerlib-redhat beaker-client beaker-redhat

# create beaker-tasks.repo file
(
	echo [beaker-tasks]
	echo name=beaker-tasks
	echo baseurl=http://beaker.engineering.redhat.com/rpms
	echo enabled=1
	echo gpgcheck=0
	echo skip_if_unavailable=1
) > /etc/yum.repos.d/beaker-tasks.repo

git_install()
{
	if [ $# -gt 0 ]; then 
		git_dir=$1
	else
		git_dir="/mnt/git_repo"
	fi

	if rpm -q git 2>/dev/null; then
		echo "Git is already installed; doing a git pull"; cd "$git_dir"/kernel; git pull
		return 0
	else
	    yum -y install git
        mkdir "$git_dir"
		cd "$git_dir" && git clone git://pkgs.devel.redhat.com/tests/kernel
	fi
}

# install git
git_install /mnt/tests

# include Beaker environment
. /mnt/tests/kernel/networking/common/include.sh || exit 1

# include common install functions
. /mnt/tests/kernel/networking/common/install.sh || exit 1

# include common networking functions
. /mnt/tests/kernel/networking/common/network.sh || exit 1
. /mnt/tests/kernel/networking/common/lib/lib_nc_sync.sh || exit 1
#. /mnt/tests/kernel/networking/common/lib/lib_netperf_all.sh || exit 1

# include private common functions
. /mnt/tests/kernel/networking/impairment/networking_common.sh || exit 1
#. /mnt/tests/kernel/networking/impairment/lib_netperf_all.sh
. /mnt/tests/kernel/networking/impairment/install.sh || exit 1
. /mnt/tests/kernel/networking/impairment/attero.sh || exit 1
. /mnt/tests/kernel/networking/openvswitch/tests/perf_check/lib_netperf_all.sh || exit 1

# install beaker-client.repo
wget -O /etc/yum.repos.d/beaker-client.repo http://download.lab.bos.redhat.com/beakerrepos/beaker-client-RedHatEnterpriseLinux.repo

# install beaker related packages
yum -y install rhts-test-env beakerlib rhts-devel rhts-python beakerlib-redhat beaker-client beaker-redhat

# set default password to be used for tests 
password=${password:-"100yard-"}

# rhel version
rhel_version=$(cut -f1 -d. /etc/redhat-release | sed 's/[^0-9]//g')

# check for installation of NetworkManager and install if necessary, enable and start service which was likley stopped by the common functions above
networkmanager_install

# pointer to netperf package
pkg_netperf=${pkg_netperf:-"http://pkgs.repoforge.org/netperf/netperf-2.6.0-1.el6.rf.x86_64.rpm"}

# variables used by netperf
netperf_time=${netperf_time:-"10"}

do_host_netperf=${do_host_netperf:-"do_host_netperf_all"}
do_vm_netperf=${do_vm_netperf:-"do_vm_netperf_all"}
tcp_threshold=${tcp_threshold:-"9000"}
udp_threshold=${udp_threshold:-"1300"}
tunnel_tcp_threshold=${tunnel_tcp_threshold:-"2500"}
tunnel_udp_threshold=${tunnel_udp_threshold:-"1300"}

# pointer to log file
result_file=${result_file:-"impairments_test_result.log"}

# specify interface and MTU to use for test
iface=${iface:-"p2p1"}
echo "The interface to be used is: $iface."

mtu=${mtu:-"1500"}
echo "The MTU to be used is: $mtu."

file_size=${file_size:-"100"}
echo "The file size to be used is: $file_size MB."

tgt_size=$(($file_size * 1048576)) 

# functions to configure static/persistent IP addresses required by impairment tests
set_ipaddr_rhel6()
{
    if [[ $host == $CLIENTS ]]; then
        ip4addr=192.168.88.100
        ip4addr_peer=192.168.88.200
        ip6addr=2014::1
        ip6addr_peer=2014::2
        #The method below calls the "cfg_static_ip" function from kernel/networking/impairment/networking_common.sh and passes the necessary arguments
        cfg_static_ip $ip4addr $ip6addr $iface $mtu

    elif [[ $host == $SERVERS ]]; then
        ip4addr=192.168.88.200
        ip4addr_peer=192.168.88.100
        ip6addr=2014::2
        ip6addr_peer=2014::1
        #The method below calls the "cfg_static_ip" function from kernel/networking/impairment/networking_common.sh and passes the necessary arguments
        cfg_static_ip $ip4addr $ip6addr $iface $mtu
    else
        echo "This host is neither $CLIENTS nor $SERVERS."
        return 1
    fi
}

set_ipaddr_rhel7()
{
    if [[ $host == $CLIENTS ]]; then
        con_name="static-$iface"
        ip4addr=192.168.88.100
        ip4addr_peer=192.168.88.200
        ip6addr=2014::1
        ip6addr_peer=2014::2
        #The method below calls functions from kernel/networking/impairment/networking_common.sh and uses nmcli to configure IP addresses
        nmcli_con_del $con_name
        nmcli_cfg_ip $con_name $iface $ip4addr/24 $ip6addr/64
        nmcli_cfg_mtu $mtu $con_name
        nmcli_con_up $con_name
    elif [[ $host == $SERVERS ]]; then
        con_name="static-$iface"
        ip4addr=192.168.88.200
        ip4addr_peer=192.168.88.100
        ip6addr=2014::2
        ip6addr_peer=2014::1
        #The method below calls functions from kernel/networking/impairment/networking_common.sh and uses nmcli to configure IP addresses
        nmcli_con_del $con_name
        nmcli_cfg_ip $con_name $iface $ip4addr/24 $ip6addr/64
        nmcli_cfg_mtu $mtu $con_name
        nmcli_con_up $con_name
    else
        echo "This host is neither $CLIENTS nor $SERVERS."
        return 1
    fi
}

#----------------------------------------------------------
alias_cfg()
{
    #Populate the/etc/host.aliases file
    echo "imp1 impairment1.knqe.lab.eng.bos.redhat.com" > /etc/host.aliases
    echo "imp2 impairment2.knqe.lab.eng.bos.redhat.com" >> /etc/host.aliases
    echo "robin robin.knqe.lab.eng.bos.redhat.com" >> /etc/host.aliases
    echo "sam sam.knqe.lab.eng.bos.redhat.com" >> /etc/host.aliases
    echo "qe1 netqe1.knqe.lab.eng.bos.redhat.com" >> /etc/host.aliases
    echo "qe2 netqe2.knqe.lab.eng.bos.redhat.com" >> /etc/host.aliases
    echo "qe3 netqe3.knqe.lab.eng.bos.redhat.com" >> /etc/host.aliases
    echo "qe4 netqe4.knqe.lab.eng.bos.redhat.com" >> /etc/host.aliases
    echo "qe5 netqe5.knqe.lab.eng.bos.redhat.com" >> /etc/host.aliases
    echo "qe6 netqe6.knqe.lab.eng.bos.redhat.com" >> /etc/host.aliases
    echo "qe7 netqe7.knqe.lab.eng.bos.redhat.com" >> /etc/host.aliases
    echo "qe8 netqe8.knqe.lab.eng.bos.redhat.com" >> /etc/host.aliases
    echo "qe9 netqe9.knqe.lab.eng.bos.redhat.com" >> /etc/host.aliases
    echo "qe10 netqe10.knqe.lab.eng.bos.redhat.com" >> /etc/host.aliases
    echo "qe11 netqe11.knqe.lab.eng.bos.redhat.com" >> /etc/host.aliases
    echo "qe12 netqe12.knqe.lab.eng.bos.redhat.com" >> /etc/host.aliases
    echo "spirent spirentimpair.knqe.lab.eng.bos.redhat.com" >> /etc/host.aliases
    echo "pnate pnate-control-01.lab.bos.redhat.com"  >> /etc/host.aliases
    echo "inf netqe-infra01.knqe.eng.rdu2.dc.redhat.com" >> /etc/host.aliases

    #Add entry to /etc/profile
    echo "export HOSTALIASES=/etc/host.aliases" >> /etc/profile

    #Source /etc/profile to activate the changes
    . /etc/profile
}

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

    # tcl
    tcl_install

    # expect
    expect_install

    # bc
    bc_install

    # xinetd
    xinetd_install

    # tftp client and server
    tftp_install

    # httpd install
    httpd_install
}

#----------------------------------------------------------

# Functions to manipulate Spirent Attero appliance

do_impairments_to_server()
{
    if i_am_client; then

       # verify connectivity to Spirent controller
        timeout 60s bash -c "until ping -c3 spirentimpair.knqe.lab.eng.bos.redhat.com; do sleep 10; done"

        # Introduce 1% packet loss with 60ms delay in direction of server
        one_pct_loss_delay_p1_p2_attero
    fi
}

do_impairments_to_client()
{
    if i_am_client; then

        # verify connectivity to Spirent controller
        timeout 60s bash -c "until ping -c3 spirentimpair.knqe.lab.eng.bos.redhat.com; do sleep 10; done"

        # Introduce 1% packet loss with 60ms delay in direction of client
        one_pct_loss_delay_p2_p1_attero
    fi
}

do_clear_attero_impairments()
{
    if i_am_client; then

        # verify connectivity to Spirent controller
        timeout 60s bash -c "until ping -c3 spirentimpair.knqe.lab.eng.bos.redhat.com; do sleep 10; done"

        # clear all impairments
        if (($mtu >= 1518)); then
            clear_attero_impairments_mtu9000
        else
            clear_attero_impairments_mtu1500
        fi
    fi
}

do_set_smallframes_attero()
{
    if i_am_client; then

        # verify connectivity to Spirent controller
        timeout 60s bash -c "until ping -c3 spirentimpair.knqe.lab.eng.bos.redhat.com; do sleep 10; done"

        # set intrinsic delay to small frames
        set_smallframes_attero
    fi
}

do_set_normalframes_attero()
{
    if i_am_client; then

        # verify connectivity to Spirent controller
        timeout 60s bash -c "until ping -c3 spirentimpair.knqe.lab.eng.bos.redhat.com; do sleep 10; done"

        # set intrinsic delay to normal frames
        set_normalframes_attero
    fi
}

do_set_jumboframes_attero()
{
    if i_am_client; then

        # verify connectivity to Spirent controller
        timeout 60s bash -c "until ping -c3 spirentimpair.knqe.lab.eng.bos.redhat.com; do sleep 10; done"

        # set intrinsic delay to normal frames
        set_jumboframes_attero
    fi
}

do_reset_attero()
{
    if i_am_client; then

        # verify connectivity to Spirent controller
        timeout 60s bash -c "until ping -c3 spirentimpair.knqe.lab.eng.bos.redhat.com; do sleep 10; done"

        # set aooliance to factory defaults
        reset_attero
    fi
}

#----------------------------------------------------------

# set up env for impairment tests

setup_env()
{
    # set up aliases for name resolution
    alias_cfg

    # stop security features
    iptables_stop_flush && setenforce 0

    if i_am_client; then

        if (($mtu >= 1518)); then
            # Reset Spirent Attero and set frame size on it to JUMBO using function from kernel/networking/impairment/attero.sh
            timeout 60s bash -c "until ping -c3 spirentimpair.knqe.lab.eng.bos.redhat.com; do sleep 10; done"
            set_jumboframes_attero

            # set MTU to 9100 bytes on Juniper switch using function from kernel/networking/impairment/networking_common.sh
            #timeout 60s bash -c "until ping -c3 pqe-pvt-jun1.knqe.lab.eng.bos.redhat.com; do sleep 10; done"
            #juniper_cfg_9100mtu
        else
            # Reset Spirent Attero and set frame size on it to normal using function from kernel/networking/impairment/attero.sh
            timeout 60s bash -c "until ping -c3 spirentimpair.knqe.lab.eng.bos.redhat.com; do sleep 10; done"
            set_normalframes_attero

            # set MTU to 1518 bytes on Juniper switch using function from kernel/networking/impairment/networking_common.sh
            #timeout 60s bash -c "until ping -c3 pqe-pvt-jun1.knqe.lab.eng.bos.redhat.com; do sleep 10; done"
            #juniper_cfg_1518mtu
        fi
    fi

    # start required services
    if (($rhel_version <= 6)); then
    service httpd start
    chkconfig httpd on

    service xinetd start
    chkconfig xinetd on
    else
    systemctl start httpd.service
    systemctl enable httpd.service

    systemctl start xinetd.service
    systemctl enable xinetd.service
    fi

    # update root password to "redhat"
#    do_rootpw_update redhat
}

#----------------------------------------------------------

# tests

do_perf()
{
        local result=0
       
        if [ $mtu -eq 1500 ]; then
	    udp_msg_size=1452
        else
            if [ $mtu -eq 9000 ]; then
	        udp_msg_size=8952
            else
	        udp_msg_size=65507
            fi
        fi
                
        if i_am_client; then
                sync_wait server test_start

                log_header "netperf tests - No Impairments" $result_file
                $do_host_netperf $ip4addr,$ip4addr_peer $ip6addr,$ip6addr_peer $result_file,$tcp_threshold,$udp_threshold "" $netperf_time $tcp_msg_size,$udp_msg_size
                result=$?

                sync_set server test_end         
        else
                sync_set client test_start
                sync_wait client test_end
        fi

        rm -f netserver.debug*

        return $result
}

do_scp4()
{
        local result=0
        
        file_name=$file_size"MBFile"
        ip4=$1
        ip4_peer=$2
        result_file=$3

        if i_am_server; then 

                if [ -e $file_name ]; then
                    rm -f $file_name
                fi
        fi

        if i_am_client; then

                act_size=$(wc -c "$file_name" | awk '{ print $1 }') || true

                if [[ -e $file_name && "$act_size" -eq "$tgt_size" ]]; then
                    echo "$file_name exists and is the correct size."
                else
                    rm -f $file_name && echo "Creating $file_name" && dd if=/dev/urandom of=$file_name bs=1M count=$file_size
                fi

                sync_wait server test_start

                sshpass -p $password scp -q -oBindAddress="$ip4" $file_name root@"$ip4_peer":"$file_name"
                sync_set server test_end
        else
                sync_set client test_start
                sync_wait client test_end

        fi

        if i_am_client; then
                rhts_submit_log -l $result_file
        fi

        return $result

}

do_scp6()
{
        local result=0
        
        file_name=$file_size"MBFile"
        ip6=$1
        ip6_peer=$2
        result_file=$3

        if i_am_server; then 

                if [ -e $file_name ]; then
                    rm -f $file_name
                fi
        fi

        if i_am_client; then

                act_size=$(wc -c "$file_name" | awk '{ print $1 }') || true

                if [[ -e $file_name && "$act_size" -eq "$tgt_size" ]]; then
                    echo "$file_name exists and is the correct size."
                else
                    rm -f $file_name && echo "Creating $file_name" && dd if=/dev/urandom of=$file_name bs=1M count=$file_size
                fi

                sync_wait server test_start

                sshpass -p $password scp -q -oBindAddress="$ip6" $file_name root@[$ip6_peer]:"$file_name"
                sync_set server test_end
        else
                sync_set client test_start
                sync_wait client test_end

        fi

        if i_am_client; then
                rhts_submit_log -l $result_file
        fi

        return $result

}

do_wget4()
{
        local result=0

        www_dir=/var/www/html
        file_name=$file_size"MBFile"
        ip4=$1
        ip4_peer=$2
        result_file=$3
                
        if i_am_server; then

                act_size=$(wc -c "$www_dir/$file_name" | awk '{ print $1 }') || true

                if [[ -e $www_dir/$file_name && "$act_size" -eq "$tgt_size" ]]; then
                    echo "$www_dir/$file_name exists and is the correct size."
                else
                    rm -f $www_dir/$file_name && echo "Creating $www_dir/$file_name" && dd if=/dev/urandom of=$www_dir/$file_name bs=1M count=$file_size
                fi
                
           	if (($rhel_version <= 6)); then
	            service httpd start
	            chkconfig httpd on
	        else
	            systemctl start httpd.service
	            systemctl enable httpd.service
	        fi
        fi

        if i_am_client; then 

                if [ -e $file_name ]; then
                    rm -f $file_name
                fi
        
                sync_wait server test_start                     

                wget -4 -nv -O $file_name --bind-address=$ip4 http://$ip4_peer/$file_name

                sync_set server test_end
        else
                sync_set client test_start
                sync_wait client test_end

        fi

        if i_am_client; then
                rhts_submit_log -l $result_file
        fi

        return $result

}

do_wget6()
{
        local result=0

        www_dir=/var/www/html
        file_name=$file_size"MBFile"
        ip4=$1
        ip4_peer=$2
        result_file=$3
                
        if i_am_server; then

                act_size=$(wc -c "$www_dir/$file_name" | awk '{ print $1 }') || true

                if [[ -e $www_dir/$file_name && "$act_size" -eq "$tgt_size" ]]; then
                    echo "$www_dir/$file_name exists and is the correct size."
                else
                    rm -f $www_dir/$file_name && echo "Creating $www_dir/$file_name" && dd if=/dev/urandom of=$www_dir/$file_name bs=1M count=$file_size
                fi
        fi

        if i_am_client; then 

                if [ -e $file_name ]; then
                    rm -f $file_name
                fi
                        
                sync_wait server test_start                     
                wget -6 -nv -O $file_name --bind-address=$ip6 http://[$ip6_peer]/$file_name
                sync_set server test_end
        else
                sync_set client test_start
                sync_wait client test_end

        fi

        if i_am_client; then
                rhts_submit_log -l $result_file
        fi

        return $result
}

do_checksum()
{

        local result=0

        if i_am_client; then
                cksum_client=$(cksum "$file_name" | awk '{ print $1 }')
                cksum_server=$(sshpass -p $password ssh root@"$SERVERS" cksum "$file_name" | awk '{ print $1 }')

                if [ "$cksum_client" -ne "$cksum_server" ]; then
                        result=1
                fi
        fi

        if i_am_client; then
                rhts_submit_log -l $result_file
        fi

        return $result

}

do_checksum_wget()
{
            local result=0

        if i_am_client; then
                cksum_client=$(cksum "$file_name" | awk '{ print $1 }')
                cksum_server=$(sshpass -p $password ssh root@"$SERVERS" cksum "$www_dir/$file_name" | awk '{ print $1 }')

                if [ "$cksum_client" -ne "$cksum_server" ]; then
                        result=1
                fi
        fi

        if i_am_client; then
                rhts_submit_log -l $result_file
        fi

        return $result

}

do_check_logs()
{
        local result=0

        if egrep -iq '/oops/|segmentation|lockup' /var/log/messages; then
            return 1
        fi

        if i_am_client; then
                rhts_submit_log -l $result_file
        fi

        return $result
}


# main
do_install
do_ssh_keygen

if [[ $host == $CLIENTS ]]; then
    # copy ssh key to server
    do_ssh_copy_id root@$SERVERS $password
fi

# configure static IP addresses
if (($rhel_version <= 6)); then
    set_ipaddr_rhel6
else
    set_ipaddr_rhel7
fi

# finish setting up environment    
setup_env
