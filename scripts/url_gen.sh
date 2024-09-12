#!/bin/bash

dbg_flag=${dbg_flag:-"set +x"}

display_usage()
{
	echo "Please provide the target git branch"
	echo "Usage: $0 <git branch>"
	echo "Example: $0 dev_branch"
}

echo ""
while true; do
    read -p "Please the target git branch name: " branch
    break
done

echo ""
echo "Test URL: https://gitlab.cee.redhat.com/ralongi/kernel/-/archive/$branch/kernel-test.tar.gz#"
echo "Merge Request URL: https://gitlab.cee.redhat.com/ralongi/kernel/-/merge_requests/new?merge_request%5Bsource_branch%5D=$branch"
