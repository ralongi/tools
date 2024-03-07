#!/bin/bash

sedeasy ()
{
sed -i "s/$(echo $1 | sed -e 's/\([[\/.*]\|\]\)/\\&/g')/$(echo $2 | sed -e 's/[\/&]/\\&/g')/g" $3
}

new_string="http://download.devel.redhat.com/rel-eng/latest-RHEL-7/compose/Server/x86_64/os/"

for i in $(ls /etc/yum.repos.d/beaker*.repo); do
	/bin/cp -f $i /tmp/"$i"_saved
	old_string=$(grep baseurl $i | awk -F "=" '{print $2}')
	sedeasy "$old_string" "$new_string" $i
done

yum clean all expire-cache
#yum provides kernel

#baseurl=http://download.lab.bos.redhat.com/released/RHEL-7/7.3/Server/x86_64/os
