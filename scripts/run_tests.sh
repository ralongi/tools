#!/bin/bash

dbg_flag=${dbg_flag:-"set +x"}
$dbg_flag
FDP_RELEASE=$1
skip_plu=${skip_plu:-"yes"}

fdp_errata_list_file=/home/ralongi/github/tools/scripts/fdp_errata_list.txt
this_file=/home/ralongi/github/tools/scripts/run_tests.sh

display_usage()
{
	echo "Please provide the FDP Release"
	echo "Usage: run_tests <FDP RELEASE>"
	echo "Example: run_tests 22j"
}

if [[ $# -lt 1 ]]; then display_usage; exit; fi

echo ""
echo "This tool will update ../openvswitch/common/package_list.sh (and check it into gitlab) based on the errata list provided in file ../scripts/fdp_errata_list.txt."
echo ""
echo "It will then execute the test runs specified in ../scripts/run_tests.sh based on the list of tests provided in file ../scripts/fdp_errata_list.txt."
echo ""

echo "Please confirm the following:"
echo ""
while true; do
    read -p "Have you confirmed that fdp_errata_list.txt has the correct information?" yn
    case $yn in
        [Yy]* ) break;;
        [Nn]* ) exit;;
        * ) echo "Please answer yes or no.";;
        esac
done
while true; do
    read -p "Have you confirmed that run_tests.sh has the correct test runs specified?" yn
    case $yn in
        [Yy]* ) break;;
        [Nn]* ) exit;;
        * ) echo "Please answer yes or no.";;
        esac
done
while true; do
    read -p "Have you run kinit?" yn
    case $yn in
        [Yy]* ) break;;
        [Nn]* ) exit;;
        * ) echo "Please answer yes or no.";;
    esac
done

# Run package_list_update.sh:
if [[ "$skip_plu" != "yes" ]]; then
	echo "Running package list update script..."
	~/github/tools/scripts/package_list_update.sh
else
	echo "Skipping package list update"
fi

# Tests to be run for $FDP_RELEASE:
/home/ralongi/github/tools/ovs_testing/run_ovs_tests.sh $FDP_RELEASE 8.4 2.13
/home/ralongi/github/tools/ovs_testing/run_ovs_tests.sh $FDP_RELEASE 8.6 2.15
#/home/ralongi/github/tools/ovs_testing/run_ovs_tests.sh $FDP_RELEASE 8.4 2.16
#/home/ralongi/github/tools/ovs_testing/run_ovs_tests.sh $FDP_RELEASE 8.6 2.17
#/home/ralongi/github/tools/ovs_testing/run_ovs_tests.sh $FDP_RELEASE 9.0 2.17

