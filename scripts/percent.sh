#!/bin/bash

#start=$1
#end=$2

# Using portfolio value (Commonwealth FR + Fidelity 401k's) as of Dec 31, 2021 as a starting value of highest known overall portfolio value
# Note that the overall portfolio value of $2,230,243 on Sep 30, 2022 is the current lowest

start=2956882
end=$1

#if [[ $# -lt 2 ]]; then
#	echo "Please provide a starting and ending value"
#	echo "Example: $0 100 150"
#	exit 1
#fi

if [[ $# -lt 1 ]]; then
	echo "Please provide a value"
	echo "Example: pct 2434774"
	exit 1
fi

delta=$(($end - $start))
pct=$(awk "BEGIN { pc=100*${delta}/${start}; i=int(pc); print (pc-i<0.5)?i:i+1 }")

echo "Starting value: $start"
echo "Ending value: $end"
echo "Change in value: $delta"
if [[ $pct -gt 0 ]]; then
	echo "There was a $pct% increase"
elif [[ $pct -lt 0 ]]; then
	pct=$(echo $pct | tr -d "-")
	echo "There was a $pct% decrease"
elif [[ $pct -eq 0 ]]; then
	echo "There was no change in the value"
fi
