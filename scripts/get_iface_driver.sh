#!/bin/bash

iface_list=$(ip l l | grep BROADCAST | awk -F ":" '{ print $2 }')
drivers=$(for i in $iface_list; do ethtool -i $i | grep driver | awk '{ print $2 }'; done)

echo $iface_list
echo $drivers
