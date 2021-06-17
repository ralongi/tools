#!/bin/bash

set -x

test_run_file=$1
template=$2
planned_in=$3
assignee=$4
if [[ $# -lt 4 ]]; then assignee=$(echo $USER); fi

min_args=2
max_args=4

display_usage()
{
	echo "$0 requires at least 3 arguments (test_run_file, template and planned_in)."
	echo "If no assignee is specified, the current user will be used."
	echo "Usage: $0 <test_run_file> <template> <planned_in> [assignee]"
	echo "Example: $0 ~/impairment_test_run.txt KN-Network_Impairment 7_3_Snap_4 [ralongi]"
}

if [[ $1 == "-h" ]] || [[ $1 == "--help" ]] || [[ $1 == "-?" ]]; then display_usage; exit 0; fi

if [[ $# -lt $min_args ]] || [[ $# -gt $max_args ]]; then display_usage; exit 1; fi

# Back up original .pylarion file and then write Polarion password to file (assumes ~/junk.txt contains the Polarion password)
/bin/cp -f ~/.pylarion ~/.pylarion.bak
sed -i "s/password=/password=$(cat ~/junk.txt)/g" ~/.pylarion

# Update the test_run.txt file with the test run name (assumes the test run should be named according to the plan being used)
/bin/cp -f $test_run_file $test_run_file"_live"
sed -i "s/run/$planned_in/g" $test_run_file"_live"

# Create the test run(s)
for i in $(cat $test_run_file"_live"); do
	pylarion-cmd update --run=$i --template=$template --plannedin=$planned_in --assignee=$assignee
done

# Execute the tests for the test run(s).  This assumes all tests have passed.
for i in $(cat $test_run_file"_live"); do
	pylarion-cmd update --run=$i --result="passed"
done

# Write original .pylarion file back
mv -f ~/.pylarion.bak ~/.pylarion
