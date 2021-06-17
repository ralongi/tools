#!/bin/bash

target=$1
current_password=$2
new_password=$3

rootpw=$(expect -c "expect '' \
  {eval spawn \
  sshpass -p $current_password ssh root@$target; \
  interact -o -nobuffer -re .*#.* return; \
  send "passwd root\r"; -re .*?.* return; \
  send "$new_password\r"; -re .*?.* return; \
  send "$new_password\r"; send -- "\r"; \
  expect eof;} ")

echo "$rootpw"
