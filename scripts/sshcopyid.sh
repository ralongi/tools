#!/bin/bash

set -x
host=$1
password=$2

/bin/cp -f /home/inf_ralongi/scripts/sshcopyid_template.exp /home/inf_ralongi/scripts/"$host"_sshcopyid.exp
sed -i "s/host/$host/g" /home/inf_ralongi/scripts/"$host"_sshcopyid.exp
sed -i "s/password/$password/g" /home/inf_ralongi/scripts/"$host"_sshcopyid.exp
expect /home/inf_ralongi/scripts/"$host"_sshcopyid.exp
