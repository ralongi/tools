#!/bin/bash

template=$1
planned_in=$2
author=$3
if [[ $# -lt 3 ]]; then author=$(echo $USER); fi

min_args=2
max_args=3

display_usage()
{
	echo "$0 requires at least 2 arguments (template name and plan name)."
	echo "If no author is specified, the current user will be used."
	echo "Usage: $0 <template> <planned_in> [author]"
	echo "Example: $0 KN-OVS-General 7_3_Beta [ralongi]"
}

if [[ $1 == "-h" ]] || [[ $1 == "--help" ]] || [[ $1 == "-?" ]]; then display_usage; exit 0; fi

if [[ $# -lt $min_args ]] || [[ $# -gt $max_args ]]; then display_usage; exit 1; fi

# Back up original pylarion.cfg file and then write Polarion password to file (assumes ~/junk.txt contains the password)
pw=$(cat ~/junk.txt) 2&>1 > /dev/null
echo $pw 2&>1 > /dev/null | sudo -S /bin/cp -f /etc/pylarion/pylarion.cfg /etc/pylarion/pylarion.bak.cfg
echo $pw 2&>1 > /dev/null | sudo -S sed -i "s/password =/password = $pw/g" /etc/pylarion/pylarion.cfg

# Update the test_run.txt file with the test run name (assumes the test run should be named according to the plan being used)
/bin/cp -f ~/test_run.txt ~/test_run_file.txt
sed -i "s/run/$planned_in/g" ~/test_run_file.txt

# Execute the necessary Polarion commands to create the test run(s)
for i in $(cat ~/test_run_file.txt); do
	pycli create -r $i -m $template -p $planned_in -a $author
done

# Write original pylarion.cfg file back
echo $pw 2&>1 > /dev/null | sudo -S mv -f /etc/pylarion/pylarion.bak.cfg /etc/pylarion/pylarion.cfg
