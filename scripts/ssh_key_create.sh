#!/bin/bash

target=$1

ssh-keygen -t rsa -N "" -f my_key

sshpass -p nomarlucy ssh-copy-id -i my_key.pub root@$target
