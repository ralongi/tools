#!/bin/bash

## Script to install virtualization on a host and get it running

yum -y group install virtualization-host-environment x11 fonts
yum -y install virt-manager virt-viewer

systemctl is-enabled libvirtd
systemctl enable libvirtd
systemctl start libvirtd

sleep 5

## Then reboot the system

systemctl reboot
