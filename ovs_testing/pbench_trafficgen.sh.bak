#!/bin/bash

rhel_version=$(cut -f1 -d. /etc/redhat-release | sed 's/[^0-9]//g')

if [[ $rhel_version -ge 8 ]]; then
	alternatives --set python /usr/bin/python3
fi

pbench-trafficgen --config=one_shot_test --devices="$pci_slot1","$pci_slot2" --frame-size="$frame_size" --traffic-direction=unidirectional --max-loss-pct=30 --num-flows=128 --rate="$pps" --samples=1 --one-shot --validation-runtime="$traffic_runtime"
