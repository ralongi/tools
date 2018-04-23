#!/bin/bash

#Populate the/etc/host.aliases file
# must be run as root
echo "imp1 impairment1.knqe.lab.eng.bos.redhat.com" > /etc/host.aliases
echo "imp2 impairment2.knqe.lab.eng.bos.redhat.com" >> /etc/host.aliases
echo "robin robin.knqe.lab.eng.bos.redhat.com" >> /etc/host.aliases
echo "sam sam.knqe.lab.eng.bos.redhat.com" >> /etc/host.aliases
echo "qe1 netqe1.knqe.lab.eng.bos.redhat.com" >> /etc/host.aliases
echo "qe2 netqe2.knqe.lab.eng.bos.redhat.com" >> /etc/host.aliases
echo "qe3 netqe3.knqe.lab.eng.bos.redhat.com" >> /etc/host.aliases
echo "qe4 netqe4.knqe.lab.eng.bos.redhat.com" >> /etc/host.aliases
echo "qe5 netqe5.knqe.lab.eng.bos.redhat.com" >> /etc/host.aliases
echo "qe6 netqe6.knqe.lab.eng.bos.redhat.com" >> /etc/host.aliases
echo "qe7 netqe7.knqe.lab.eng.bos.redhat.com" >> /etc/host.aliases
echo "qe8 netqe8.knqe.lab.eng.bos.redhat.com" >> /etc/host.aliases
echo "qe9 netqe9.knqe.lab.eng.bos.redhat.com" >> /etc/host.aliases
echo "qe10 netqe10.knqe.lab.eng.bos.redhat.com" >> /etc/host.aliases
echo "qe11 netqe11.knqe.lab.eng.bos.redhat.com" >> /etc/host.aliases
echo "qe12 netqe12.knqe.lab.eng.bos.redhat.com" >> /etc/host.aliases
echo "qe13 netqe13.knqe.lab.eng.bos.redhat.com" >> /etc/host.aliases
echo "qe14 netqe14.knqe.lab.eng.bos.redhat.com" >> /etc/host.aliases
echo "qe15 netqe15.knqe.lab.eng.bos.redhat.com" >> /etc/host.aliases
echo "qe16 netqe16.knqe.lab.eng.bos.redhat.com" >> /etc/host.aliases
echo "qe17 netqe17.knqe.lab.eng.bos.redhat.com" >> /etc/host.aliases
echo "spirent spirentimpair.knqe.lab.eng.bos.redhat.com" >> /etc/host.aliases
echo "pnate pnate-control-01.lab.bos.redhat.com"  >> /etc/host.aliases
echo "inf netqe-infra01.knqe.lab.eng.bos.redhat.com" >> /etc/host.aliases
echo "10.19.40.183 cube1" >> /etc/hosts
echo "10.19.40.108 cube2" >> /etc/hosts
echo "qe18 netqe18.knqe.lab.eng.bos.redhat.com" >> /etc/host.aliases
echo "qe19 netqe19.knqe.lab.eng.bos.redhat.com" >> /etc/host.aliases
echo "qe20 netqe20.knqe.lab.eng.bos.redhat.com" >> /etc/host.aliases
echo "qe21 netqe21.knqe.lab.eng.bos.redhat.com" >> /etc/host.aliases
echo "qe22 netqe22.knqe.lab.eng.bos.redhat.com" >> /etc/host.aliases
echo "qe23 netqe23.knqe.lab.eng.bos.redhat.com" >> /etc/host.aliases
echo "qe24 netqe24.knqe.lab.eng.bos.redhat.com" >> /etc/host.aliases
echo "qe25 netqe25.knqe.lab.eng.bos.redhat.com" >> /etc/host.aliases
echo "qe26 netqe26.knqe.lab.eng.bos.redhat.com" >> /etc/host.aliases

#Add entry to /etc/profile
echo "export HOSTALIASES=/etc/host.aliases" >> /etc/profile

#Source /etc/profile to activate the changes
. /etc/profile

