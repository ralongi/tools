#!/bin/bash

. /home/ralongi/scripts/bash_functions

cfg_ip_nic "199.199.199.199/24" p2p1
cfg_ip_nic "2019::99/64" p2p1

cfg_mtu 1500 p2p1

cmd $(ip link show p2p1)
cmd $(ip addr)
