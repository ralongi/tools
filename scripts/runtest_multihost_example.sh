#!/bin/bash
# vim: dict=/usr/share/beakerlib/dictionary.vim cpt=.,w,b,u,t,i,k
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   runtest.sh of /kernel/networking/route/source_routing
#   Description: route/source_routing
#   Author: Hangbin Liu <haliu@redhat.com>
#
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   Copyright (c) 2012 Red Hat, Inc. All rights reserved.
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

# Include Beaker environment
. /usr/bin/rhts-environment.sh
. /usr/lib/beakerlib/beakerlib.sh

set -x
cur_iface=`ip route show | awk '/default/{print $5}'`

# Verify Source Routing have executed
check_routing()
{
    local src=$1
    local dst=$2
    local family=$3

    tcpdump -i $cur_iface -nn -l icmp${family} > dump.log &

    local pid=$!
    sleep 5
    ping${family} $dst -c 2
    sleep 1
    kill $pid

    cat dump.log >> $OUTPUTFILE
    if grep -rin "$src > $dst.*echo request" dump.log ;then
        report_result "${TEST}/${src}_to_${dst}" "PASS"
    else
        report_result "${TEST}/${src}_to_${dst}" "FAIL"
    fi
}

server()
{
    rhts-sync-block -s Client_ready $CLIENTS

    # Try IPv4 Source Routing

    ## Set ip address
    ip link set ${cur_iface} alias ${cur_iface}:1
    ip addr add 192.168.100.1/24 dev ${cur_iface}:1
    ip link set ${cur_iface} alias ${cur_iface}:2
    ip addr add 192.168.200.1/24 dev ${cur_iface}:2

    ## get default route
    ## This route is predictable, they must route to the same subnet 
    ip route get 192.168.100.2
    ip route get 192.168.200.2

    ## set new route
    ip route add 192.168.100.2 via 192.168.100.2 src 192.168.200.1
    ip route add 192.168.200.2 via 192.168.200.2 src 192.168.100.1

    ## Verify default route changed
    ip route get 192.168.100.2
    ip route get 192.168.200.2

    ## Check Routing
    check_routing 192.168.100.1 192.168.200.2
    check_routing 192.168.200.1 192.168.100.2

    # Try IPv6 Source Routing

    ## Add IPv6 address
    ip addr add 2012::11/64 dev $cur_iface
    ip addr add 2012::12/64 dev $cur_iface

    ## Get default route
    ip -6 route get 2012::21
    ip -6 route get 2012::22

    ## Set new IPv6 route
    ip -6 route add 2012::21 via 2012::21 src 2012::11
    ip -6 route add 2012::22 via 2012::22 src 2012::12

    ## Verify route
    ip -6 route get 2012::21
    ip -6 route get 2012::21

    ## Check Routing
    check_routing 2012::11 2012::21 6
    check_routing 2012::12 2012::22 6

    rhts-sync-set -s Server_done
    # Clean up environment
    service network restart
}

client()
{
    # Set IPv4 Address
    ip link set ${cur_iface} alias ${cur_iface}:1
    ip addr add 192.168.100.2/24 dev ${cur_iface}:1
    ip link set ${cur_iface} alias ${cur_iface}:2
    ip addr add 192.168.200.2/24 dev ${cur_iface}:2

    # Set IPv6 Address

    ip addr add 2012::21/64 dev $cur_iface
    ip addr add 2012::22/64 dev $cur_iface

    # Wait server testing
    rhts-sync-set -s Client_ready
    rhts-sync-block -s Server_done $SERVERS

    report_result "${TEST}/Client" "PASS"

    # Clean up environment
    service network restart
}

#------------------- Start Test --------------------

if [ -z "$JOBID" ];
then
    echo "Variable jobid not set! Assume developer mode."
    echo "Don't run on single machine, quit."
    exit
fi

if [ -z "$SERVERS" -o -z "$CLIENTS" ];
then
    echo "Cannot determine test type! Client/Server failed."
    report_result $TEST/no_ser_or_cli FAIL
    exit
fi

HOSTNAME=`hostname`
if $(echo $SERVERS | grep -q -i $HOSTNAME);
then
    TEST="$TEST/Server"
    server
fi

if $(echo $CLIENTS | grep -q -i $HOSTNAME);
then
    TEST="$TEST/Client"
    client
fi
