#!/bin/bash

want_host=$1
if [[ ! $1 ]]; then
	echo "Please provide hostname"
	exit 1
fi

tpsserv-checkin-tpsd -f $want_host | grep ^test_profile | grep -v updated
