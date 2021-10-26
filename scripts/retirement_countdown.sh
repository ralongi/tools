#!/bin/bash

today=$(echo $(date +%F))
retirement_date="2022-08-12"
#retirement_date="2050-08-12"

weeks_until_retirement=$(datediff $today $retirement_date -f '%w')

echo "$weeks_until_retirement more Mondays to go!"

