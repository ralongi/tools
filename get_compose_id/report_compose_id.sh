#!/bin/bash

dbg_flag=${dbg_flag:-"set +x"}
$dbg_flag

# Script to log into target host and obtain compose ID

target=$1
password=$2
default_password="100yard-"

if [[ $# -lt 1 ]]; then
    echo "You must specify a target host and root password: $0 <target_host> [root pw])."
    echo "Password 100yard- will be used if no password is provided"
    exit
fi

if [[ $# -lt 2 ]]; then
    password="$default_password"
fi

echo ""
echo "Logging into $target..."

if [[ ! $(rpm -q epel-release) ]]; then
    echo "Installing EPEL repo..."
    timeout 10s bash -c "until ping -c3 dl.fedoraproject.org; do sleep 10; done"
    yum -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-$rhel_version.noarch.rpm
fi

if [[ ! $(which sshpass) ]]; then
    echo "Installing sshpass..."
    yum -y install sshpass
fi

nslookup $target > /dev/null
if [[ $? -ne 0 ]]; then
     echo "$target does not appear to be a valid FQDN.  Please enter a valid FQDN target."
     exit 0
fi

timeout 10s bash -c "until traceroute $target > /dev/null; do sleep 1s; done"
if [[ $? -ne 0 ]]; then
    echo "$target is not reachable.  Exiting test..."
    exit
fi

cat /home/ralongi/github/tools/get_compose_id/get_compose_id.sh | sshpass -p $password ssh -q -o "StrictHostKeyChecking= no" root@$target 'bash -'

