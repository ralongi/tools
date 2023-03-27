#!/bin/bash

$dbg_flag

sleep_time="30m"

echo ""
echo "Running beaker_cancel_stuck_jobs.sh every $sleep_time..."
echo ""

while [ 1 ]; do
	#echo "Running kinit..."
	#kinit ralongi@REDHAT.COM -k -t /home/ralongi/kerberos/ralongi.keytab
	echo ""
	echo "Running beaker_cancel_stuck_jobs.sh..."
	echo ""
	/home/ralongi/github/tools/scripts/beaker_cancel_stuck_jobs.sh
	echo "Time: $(date)"
	echo "Sleeping $sleep_time..."
	echo ""
	sleep $sleep_time
done
	
