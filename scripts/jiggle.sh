#!/bin/bash

# This script fools your computer into thinking there is mouse activity so the computer won't go to sleep

while true; do
    xdotool mousemove_relative --sync -- -1 0
    xdotool mousemove_relative 1 0
    sleep 60
done
