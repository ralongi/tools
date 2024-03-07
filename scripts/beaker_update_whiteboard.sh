#!/bin/bash

# script to update whiteboard on beaker jobs

min_id=$1
max_id=$2

display_usage()
{
	echo "This script will delete your beaker jobs as specified"
	echo "Usage: $0 <min_id> [max_id]"
	echo "Examples:\n"
	echo "$0 J:2594821 (to delete J:2594821)"
	echo "$0 2594821 2594828 (to delete J:2594821 through J:2594828)"
	exit 0
}

if [[ $# -lt 1 ]] || [[ $1 = "-h" ]] || [[ $1 = "--help" ]]	|| [[ $1 = "-?" ]]; then
	display_usage
fi

if [[ -z $max_id ]]; then max_id=$min_id; fi

echo "Starting Job ID: $min_id"
echo "Ending Job ID: $max_id"

jobs=$(bkr job-list --mine --min-id "$min_id" --max-id "$max_id" | tr -d '[],"')

pushd ~/temp
rm -f wb.txt && touch wb.txt && chmod 777 wb.txt

for job in $jobs; do
	bkr job-clone --prettyxml --dryrun $job | grep -A1 '<whiteboard>' | tee wb.txt
	x=$(sed 's/  <whiteboard>//g' wb.txt)
	old_wb=$(echo $x | sed 's/<\/whiteboard>//g')
	new_wb=$(echo $old_wb | sed 's/22G/23G/g')
	bkr job-modify --whiteboard "$new_wb" $job
done
rm -f wb.txt
popd
