#!/bin/bash

pssh -x "-T" -i -h /home/ralongi/scripts/hosts/robin.txt -I < /home/ralongi/scripts/robin_ns_ovs_cfg.sh
pssh -x "-T" -i -h /home/ralongi/scripts/hosts/sam.txt -I < /home/ralongi/scripts/sam_ns_ovs_cfg.sh
