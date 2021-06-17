#!/bin/bash

#to delete "|panic" from all .sh files

sed -i 's/|panic//g' *.sh
