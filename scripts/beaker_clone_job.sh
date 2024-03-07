#!/bin/bash

# script to clone beaker jobs

min_id=$1
max_id=$2

display_usage()
{
	echo "This script will clone your beaker jobs as specified"
	echo "Usage: $0 <min_id> [max_id]"
	echo "Examples:\n"
	echo "$0 J:2594821 (to cancel J:2594821)"
	echo "$0 2594821 2594828 (to cancel J:2594821 through J:2594828)"
	exit 0
}

if [[ $# -lt 1 ]] || [[ $1 = "-h" ]] || [[ $1 = "--help" ]]	|| [[ $1 = "-?" ]]; then
	display_usage
fi

if [[ -z $max_id ]]; then max_id=$min_id; fi

echo "Starting Job ID: $min_id"
echo "Ending Job ID: $max_id"

jobs=$(bkr job-list --mine --min-id "$min_id" --max-id "$max_id" | tr -d '[],"')

for job in $jobs; do bkr job-clone $job; done

