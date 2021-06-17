#!/bin/bash

# script to do a batch beaker tag operation

base_dir="/home/ralongi/kernel/networking"

for i in [ openvswitch/tests/perf_check/ impairment/tests/no_impairments/ impairment/tests/1pct_loss_60ms_delay/ impairment/tests/3pct_loss_60ms_delay/ impairment/tests/5pct_loss_60ms_delay/ impairment/tests/combo_1/ impairment/tests/hdr_overwrite/ ]; do
	cd "$base_dir"/"$i"
	make tag
	git push --tags
	make bkradd
done
