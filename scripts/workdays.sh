#!/bin/bash

$dbg_flag

start_date=$(date +%F)
end_date="2026-04-03"

# Function to calculate the number of weekdays between two dates
calculate_weekdays() {
  #start_date="$1"
  #end_date="$2"

  # Convert dates to timestamps
  start_ts=$(date -d "$start_date" +%s)
  end_ts=$(date -d "$end_date" +%s)

  # Check if the start date is after the end date
  if [[ "$start_ts" -gt "$end_ts" ]]; then
    echo "Error: Start date must be before end date."
    return 1
  fi

  # Calculate the number of days between the two dates
  total_days=$(( (end_ts - start_ts) / (60 * 60 * 24) + 1 ))

  weekdays=0
  # Loop through each day and count weekdays
  for ((i = 0; i < total_days; i++)); do
    current_ts=$((start_ts + i * 60 * 60 * 24))
    day_of_week=$(date -d "@$current_ts" +%u) # 1 (Monday) - 7 (Sunday)

    # Check if the current day is a weekday (1-5)
    if [[ "$day_of_week" -le 5 ]]; then
      weekdays=$((weekdays + 1))
    fi
  done
    
  echo "$weekdays"
}

count_mondays() {
  #start_date="$1"
  #end_date="$2"
  start_date=$(date +%F)
  end_date="2026-04-03"
  count=0

  # Convert dates to timestamps
  start_ts=$(date -d "$start_date" +%s)
  end_ts=$(date -d "$end_date" +%s)

  # Loop through each day between the start and end dates
  for ((ts=start_ts; ts<=end_ts; ts+=86400)); do
    # Get the day of the week (0-6, where 1 is Monday)
    day_of_week=$(date -d "@$ts" +%u)

    # If the day is Monday, increment the count
    if [ "$day_of_week" -eq 1 ]; then
      ((count++))
    fi
  done
  echo "$count"
}

# Main script
#if [[ $# -ne 2 ]]; then
#  echo "Usage: $0 <start_date> <end_date>"
#  echo "Date format: YYYY-MM-DD"
#  exit 1
#fi

#start_date="$1"
#end_date="$2"

# Validate date format
if ! [[ "$start_date" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]] || ! [[ "$end_date" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]]; then
  echo "Error: Invalid date format. Use YYYY-MM-DD."
  exit 1
fi

weekdays=$(calculate_weekdays "$start_date" "$end_date")

#echo "Number of weekdays between $start_date and $end_date: $weekdays"
echo "Enter number of non-working weekdays ahead (PTO, holidays, etc):"; read free_days

working_days=$(( $weekdays - $free_days ))
echo "Number of working days left between $start_date and $end_date: $working_days"

num_mondays=$(count_mondays "$1" "$2")
start_ts=$(date -d "$start_date" +%s)
start_day_of_week=$(date -d "@$start_ts" +%u)
if [[ $start_day_of_week -eq 1 ]]; then num_mondays=$((( $num_mondays - 1 ))); fi
echo "Number of calendar Mondays between $start_date and $end_date: $num_mondays (Don't forget you will be taking some of these Mondays off!)"

