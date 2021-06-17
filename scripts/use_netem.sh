#!/bin/bash
#
# Usage: ./use_netem.sh $argument

if [ $# -eq 0 ]
   then
    echo ""
    echo "off     = clear all netem profiles"
    echo "show    = show active profiles"
    echo "samoa   = enable Samoa netem profile"
    echo ""
   exit
 fi

if [ $1 = "off" ]
   then
     echo "netem profile off"
     tc qdisc del dev p2p1 root netem
   exit
 fi

if [ $1 = "show" ]
   then
     echo "show netem profile"
     tc qdisc show dev p2p1
   exit
 fi

if [ $1 = "samoa" ]
   then
     tc qdisc add dev p2p1 root netem delay 200ms 40ms 25% loss 15.3% 25% duplicate 1% corrupt 0.1% reorder 25% 50%
   exit
 fi

#### EOF #####
