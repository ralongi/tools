#!/bin/bash

result_file=~/gci_output.txt
rm -f $result_file

export compose_id=$(grep 'server=' /root/anaconda-ks.cfg | grep nfs | awk -F "/" '{print $(NF-5)}')

echo "COMPOSE_ID is: $compose_id"
