#!/bin/bash

pssh -h /home/inf_ralongi/scripts/pssh_nfs_hosts -l root ping -c3 ralongi-home.usersys.redhat.com
pssh -h /home/inf_ralongi/scripts/pssh_nfs_hosts -l root systemctl restart nfs-server
sleep 10
echo $(cat /home/ralongi/junk.txt) | sudo -S systemctl restart autofs
sleep 10
ls /home/inf_ralongi/
ls /home/work
