#!/bin/bash

#echo "$current_exports_ip"
#echo "$current_laptop_ip"
sed -i 's/10.22.17.87/10.22.17.97/g' /etc/exports
#sedeasy "$current_exports_ip" "$current_laptop_ip" "/etc/exports"
