#!/bin/bash

/bin/cp -f /home/ralongi/.did/config_no_git /home/ralongi/.did/config
did_results_file="/home/ralongi/Documents/status_reports/did_results.txt"
period=$(echo "$1 $2")
rm -f $did_results_file && touch $did_results_file
did $(echo $period) > $did_results_file
/bin/cp -f /home/ralongi/.did/config_git /home/ralongi/.did/config
did $(echo $period) > /tmp/did_results.tmp
sed -i 's/~/ /g' /tmp/did_results.tmp
cat /tmp/did_results.tmp >> $did_results_file
awk '!/^Status/ || !f++' $did_results_file > $did_results_file.tmp && mv -f $did_results_file.tmp $did_results_file
awk '!/ralongi@redhat.com/ || !f++' $did_results_file > $did_results_file.tmp && mv -f $did_results_file.tmp $did_results_file
cat $did_results_file
