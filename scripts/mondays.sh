#!/bin/bash

$dbg_flag

start_date=${start_date:-$(date +%F)}
end_date="2026-04-03"

count_mondays() {
  start_date=$start_date
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

# Validate date format
if ! [[ "$start_date" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]] || ! [[ "$end_date" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]]; then
  echo "Error: Invalid date format. Use YYYY-MM-DD."
  exit 1
fi

num_mondays=$(count_mondays "$1" "$2")
start_ts=$(date -d "$start_date" +%s)
start_day_of_week=$(date -d "@$start_ts" +%u)
if [[ $start_day_of_week -eq 1 ]]; then num_mondays=$((( $num_mondays - 1 ))); fi
echo "Number of calendar Mondays between $start_date and $end_date: $num_mondays" #(Don't forget you will be taking some of these Mondays off!)

