#!/bin/bash

#Create sub-directories
IPV4_DIR=/home/jhsiao/nic-ovs-tunnel-test/ipv4
IPV6_DIR=/home/jhsiao/nic-ovs-tunnel-test/ipv6

[ ! -d $IPV4_DIR ] && mkdir -p $IPV4_DIR
[ ! -d $IPV6_DIR ] && mkdir -p $IPV6_DIR

#Copy original script mfiles into new directories
/bin/cp -f /home/jhsiao/nic-ovs-tunnel-test/* /home/jhsiao/nic-ovs-tunnel-test/ipv4; rm -f /home/jhsiao/nic-ovs-tunnel-test/ipv4/mylog*
/bin/cp -f /home/jhsiao/nic-ovs-tunnel-test/* /home/jhsiao/nic-ovs-tunnel-test/ipv6; rm -f /home/jhsiao/nic-ovs-tunnel-test/ipv6/mylog*

#Modify script files in new directory as necessary
sed -i -- 's/IP/IP4/g' /home/jhsiao/nic-ovs-tunnel-test/ipv4/*.sh
sed -i -- 's/IP/IP6/g' /home/jhsiao/nic-ovs-tunnel-test/ipv6/*.sh
sed -i -- 's/192.168.13.10/2013::10/g' /home/jhsiao/nic-ovs-tunnel-test/ipv6/*.sh
sed -i -- 's/192.168.3.10/2003::10/g' /home/jhsiao/nic-ovs-tunnel-test/ipv6/*.sh
sed -i -- 's/192.168.3.20/2003::20/g' /home/jhsiao/nic-ovs-tunnel-test/ipv6/*.sh
sed -i -- 's/192.168.13.20/2013::20/g' /home/jhsiao/nic-ovs-tunnel-test/ipv6/*.sh
sed -i -- 's/\/24/\/64/g' /home/jhsiao/nic-ovs-tunnel-test/ipv6/*.sh
sed -i -- 's/tunnel-test/tunnel-test\/ipv4/g' /home/jhsiao/nic-ovs-tunnel-test/ipv4/*.sh
sed -i -- 's/tunnel-test/tunnel-test\/ipv6/g' /home/jhsiao/nic-ovs-tunnel-test/ipv6/*.sh

#Copy IPv4 and IPv6 versions of runtest_netperf.sh and runtest.sh down to local machines
cd /home/jhsiao/nic-ovs-tunnel-test/ipv4
wget http://ralongi.usersys.redhat.com/runtest_netperf4.sh; wget http://ralongi.usersys.redhat.com/runtest_ipv4.sh
cd /home/jhsiao/nic-ovs-tunnel-test/ipv6
wget http://ralongi.usersys.redhat.com/runtest_netperf6.sh; wget http://ralongi.usersys.redhat.com/runtest_ipv6.sh

#Set executable bit on all scripts
chmod +x /home/jhsiao/nic-ovs-tunnel-test/ipv4/*.sh
chmod +x /home/jhsiao/nic-ovs-tunnel-test/ipv6/*.sh
