#!/bin/bash
. /home/ralongi/scripts/bash_functions

DIR=$1/
LOGDIR="/home/ralongi/scripts/impairment/logs/$DIR"

grep -i 'calculated average throughput after' "$LOGDIR"*.log
grep -i 'calculated average throughput after' "$LOGDIR"*.log | awk '{ print $9 }'
