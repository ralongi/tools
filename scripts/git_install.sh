#!/bin/bash

yum -y install git
mkdir /mnt/tests && cd /mnt/tests
git clone git://pkgs.devel.redhat.com/tests/kernel

