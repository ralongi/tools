#!/bin/bash

HOST=$1

ssh-copy-id -i /home/ralongi/.ssh/rick_rsa.pub root@$HOST
