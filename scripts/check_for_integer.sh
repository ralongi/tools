#!/bin/bash

target_variable=$1
if [[ $# -lt 1 ]]; then
	echo "Please provide the target variable to be checked."
	echo "Example: $0 \$variable_name"
	exit 0
fi

if expr "$target_variable" : '-\?[0-9]\+$' >/dev/null; then
	echo "$target_variable is considered an integer."	    
else
    echo "$target_variable is NOT considered an integer."
fi

