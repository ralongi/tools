#!/bin/bash

# script to calculate how Matt is tracking to his weekly budget

budget=100
start_date=$1
end_date=$2
spent=$3

if [[ $# -lt 3 ]]; then
	echo "You must enter a start date, end date and dollar amount spent."
	echo "Example: $0 9/1/17 9/6/17 150.00"
	exit 0
fi

money_spent=$(printf "%.0f" "$spent")
budget_available=$(printf "%.0f" "$budget")

budget_delta=$(($budget_available - $money_spent))
budget_delta_absolute=$(echo $budget_delta | tr -d "-")
calc_percentage()
{
	var1=$(echo $(($money_spent - $budget_available)) / $budget_available | bc -l)
	var2=$(printf "%.2f" "$var1")
	var3=$(echo $var2*100 | bc)
	budget_percent=$(printf "%.0f" "$var3")
}
calc_percentage

if [[ $budget_delta -gt 0 ]]; then
	budget_report="$""$budget_delta_absolute under budget"
elif [[ $budget_delta -lt 0 ]]; then
	budget_report="$""$budget_delta_absolute ("$budget_percent"%) over budget"
else
	budget_report="right on budget"
fi

echo "You spent $"$money_spent" during the week of $start_date to $end_date.  The budget available for you to spend was $"$budget_available".  Based on this data, you were "$budget_report" for the week of $start_date to $end_date."

