# Script to use awk to replace a string only on lines that contain a specific string

#!/bin/bash

#Set the target file(s) to be modified in the current working directory (i.e. *.sh) 

TARGET="*.sh"

#Run the awk command against the files and write the changes to the files

#In this example, look for all lines containing the string TESTDIR= and then replace the string impairment with impairment/4GB_files
#So TESTDIR="/home/ralongi/scripts/impairment/" would become TESTDIR="/home/ralongi/scripts/impairment/4GB_files/"

for i in $TARGET; do awk '/TESTDIR=/ { gsub(/impairment/, "impairment/4GB_files") }; { print }' $i > tmp && mv -f tmp $i; done
