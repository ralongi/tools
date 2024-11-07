#!/bin/bash

branch=${branch:-$1}
if [[ -z $branch ]]; then branch="ralongi_test"; fi
pushd /home/ralongi/git/my_fork/kernel/networking
if [[ $(git status | grep 'On branch' | awk '{print $NF}') != "master" ]]; then
	git checkout master
fi
git pull && git pull origin master --rebase && git checkout -b $branch
popd
