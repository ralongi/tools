#!/bin/bash

pssh -x "-T" -i -h /NotBackedUp/ralongi/scripts/hosts/robin.txt -I < /NotBackedUp/ralongi/scripts/robin_bridge_cfg.sh
pssh -x "-T" -i -h /NotBackedUp/ralongi/scripts/hosts/sam.txt -I < /NotBackedUp/ralongi/scripts/sam_bridge_cfg.sh
