#!/bin/bash

. /home/ralongi/scripts/networking_common.sh

set -x
set -e

REMOTE_MGMT="qe-dell-impairment2.lab.eng.bos.redhat.com"
TESTFILE_DIR=/home/testfiles
[ ! -d $TESTFILE_DIR ] && mkdir -p $TESTFILE_DIR || true

#set up remote tftp server
ssh root@$REMOTE_MGMT << EOF
/bin/cp -f /etc/xinetd.d/tftp /home/xinetd_tftp_bak
scp root@ralongi.usersys.redhat.com:/VirtualMachines/backups/imp2/tftp /etc/xinetd.d/
[ ! -d $TESTFILE_DIR ] && mkdir -p $TESTFILE_DIR || true
chmod 777 $TESTFILE_DIR
setenforce 0
service iptables stop || true
iptables -F
service xinetd restart
EOF


