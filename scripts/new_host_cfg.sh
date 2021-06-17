#!/bin/bash

set -ex

HOST=$1

scp /home/ralongi/Documents/scripts/repos/*.repo root@$HOST:/etc/yum.repos.d

ssh root@$HOST < /home/ralongi/Documents/scripts/fresh_install/new_install_packages.sh
