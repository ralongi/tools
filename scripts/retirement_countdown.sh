#!/bin/bash

today=$(echo $(date +%F))
retirement_notice_date="2025-10-12"
retirement_date="2026-08-12"

weeks_until_retirement_notice=$(datediff $today $retirement_notice_date -f '%w')
weeks_until_retirement=$(datediff $today $retirement_date -f '%w')

echo "$weeks_until_retirement_notice more Mondays to go before you can give your retirement notice!"
echo "$weeks_until_retirement more Mondays to go until retirement!"
