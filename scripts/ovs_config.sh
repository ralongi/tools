#!/bin/bash

# copy functions up to hosts for later use
sshpass -p 100yard- scp /home/ralongi/Documents/scripts/ovs_runtest_functions.sh root@qe7:/tmp
sshpass -p 100yard- scp /home/ralongi/Documents/scripts/ovs_runtest_functions.sh root@qe8:/tmp

# execute config script on hosts
sshpass -p 100yard- ssh root@qe7 < /home/ralongi/Documents/scripts/manual_cfg_ovs.sh
sshpass -p 100yard- ssh root@qe8 < /home/ralongi/Documents/scripts/manual_cfg_ovs.sh
