#!/bin/bash

#Insert a "#" at the beginning of every line that contains the string "PKTS_" in all *.sh files
#sed -i '/PKTS_/ s/^/#/' *.sh

#Remove the first character from every line that contains the string "PKTS_" in all *.sh files (add a "." for the number of characters you want to remove)
sed -i '/PKTS_/ s/^.//' *.sh


