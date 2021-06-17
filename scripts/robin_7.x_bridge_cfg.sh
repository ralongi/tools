#!/bin/bash

nmcli con add con-name br0 ifname br0 type bridge ip4 192.168.88.100/24
nmcli con add type bridge-slave con-name br0-slave-1 ifname enp7s0f1 master br0
nmcli con up br0

