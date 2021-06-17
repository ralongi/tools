#!/bin/bash

target=$1
password=$2

SSHCOPY=$(expect -c "expect '' \
  {eval spawn \
  ssh-copy-id -i root@$target; \
  interact -o -nobuffer -re .*assword.* return; \
  send "$password\r"; send -- "\r"; \
  expect eof;} ")

echo "$SSHCOPY"

