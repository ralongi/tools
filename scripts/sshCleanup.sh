#!/bin/bash

dbg_flag=${dbg_flag:-"set +x"}
$dbg_flag

set -x
host=$1
password=$2
if [[ $# -lt 2 ]]; then password="100yard-"; fi

user=$3
if [[ $# -lt 3 ]]; then user="root"; fi

timeout 5 traceroute $host > /dev/null
if [[ $? -ne 0 ]]; then
	echo "$host is not responding.  Unable to perform ssh-copy-id operation."
	exit 0
fi

expect /home/ralongi/inf_ralongi/scripts/"$user"_"$host"_sshcopyid.exp

echo "$(grep -iv "$host" ~/.ssh/known_hosts)" > ~/.ssh/known_hosts

/bin/cp -f /home/ralongi/inf_ralongi/scripts/sshcopyid_template.exp /home/ralongi/inf_ralongi/scripts/"$user"_"$host"_sshcopyid.exp
sed -i "s/host/$host/g" /home/ralongi/inf_ralongi/scripts/"$user"_"$host"_sshcopyid.exp
sed -i "s/pw/$password/g" /home/ralongi/inf_ralongi/scripts/"$user"_"$host"_sshcopyid.exp
sed -i "s/name/$user/g" /home/ralongi/inf_ralongi/scripts/"$user"_"$host"_sshcopyid.exp

timeout 5 traceroute $host > /dev/null
if [[ $? -ne 0 ]]; then
	echo "$host is not responding.  Unable to perform ssh-copy-id operation."
	exit 1
fi
expect /home/ralongi/inf_ralongi/scripts/"$user"_"$host"_sshcopyid.exp

