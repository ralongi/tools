#!/bin/bash

export compose_id=$(grep 'server=' /root/anaconda-ks.cfg | grep nfs | awk -F "/" '{print $(NF-5)}')
echo ""
echo "Compose ID on $(hostname) is: $compose_id"
echo "Running kernel version is: $(uname -r)"
echo ""
