#!/bin/bash

# Bash script to prep for using create-errata.py and to then launch create-errata.py using options provided to script
# Must first clone git@gitlab.cee.redhat.com:nst/openvswitch/ovs-maintainer-scripts.git
# This script keys off of what is set for GIT_HOME variable value and assumes above repo was cloned there
# Make sure you have created ~/.env with the following contents (without the #):
#ERRATA_OWNER_EMAIL=user@redhat.com
#JIRA_OWNER_EMAIL=user@redhat.com
#JIRA_TOKEN=XXX

$dbg_flag

FDP_RELEASE=$1
NVR=$2
GIT_HOME=~/git

display_usage()
{
	echo "Usage: $0 <FDP Release> <NVR>"
	echo "Example: $0 25.C openvswitch3.3-3.3.4-104.el9fdp"
}

if [[ $# == "--help" || $# == "help" || $# == "-h" || $# == "-?" || $# -lt 2 ]]
then
    display_usage
    exit 0
fi

# Activate virtual python environment
pushd ~
python3 -m venv venv

# Install  necessary packages
pip install --upgrade pip
pip install errata-tool

# Make sure the latest create-errata.py is used
pushd $GIT_HOME/ovs-maintainer-scripts/
git pull
wait

# Copy create-errata.py to /usr/local/bin where .env file is located
/bin/cp -f create-errata.py ~
popd

create-errata.py $FDP_RELEASE $NVR
popd

