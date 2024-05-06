#!/bin/bash

bos_3200_ports_file=~/bos_3200_ports.txt
bos_3903_ports_file=~/bos_3903_ports.txt
bos_anl_3200_ports_file=~/bos_anl_3200_ports.txt
nay_3200_ports_file=~/nay_3200_ports.txt
nay_3901_ports_file=~/nay_3901_ports.txt

. ~/.bashrc

ns_show_ports bos_3200 | tee $bos_3200_ports_file
sed -i '1,6d' $bos_3200_ports_file

ns_show_ports bos_3903 | tee $bos_3903_ports_file
sed -i '1,6d' $bos_3903_ports_file

ns_show_ports bos_anl_3200 | tee $bos_anl_3200_ports_file
sed -i '1,6d' $bos_anl_3200_ports_file


