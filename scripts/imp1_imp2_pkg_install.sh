
#Create user "ralongi"
ssh root@imp1 useradd ralongi
ssh root@imp2 useradd ralongi


#install netperf
rpm -ivh http://pkgs.repoforge.org/netperf/netperf-2.6.0-1.el6.rf.x86_64.rpm

#install EPEL
sudo wget http://download.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm
sudo rpm -ivh epel-release-6-8.noarch.rpm

#Install TCL
yum -y install tcl

#Install Expect
yum -y install expect

#Install bc
yum -y install bc

#Install pciutils (for lspci, etc.)
yum -y install pciutils

#Install yum utils to access commands like yum-config-manager
yum -y install yum-utils

#Install net-tools for things like ifconfig
yum -y install net-tools

#Install tftp client and server for testing
yum -y install tftp
yum -y install tftp-server

#enable tftp server and set IPv6 flag to use both IPv4 and IPv6
awk '/disable/ { sub(/yes/, "no") }; { print }' /etc/xinetd.d/tftp > tmp && mv -f tmp /etc/xinetd.d/tftp
mkdir /tftpboot
awk '/server_args/ { sub("/-s /var/lib/tftpboot/", "-c -s /tftpboot") }; { print }' /etc/xinetd.d/tftp > tmp && mv -f tmp /etc/xinetd.d/tftp
sed -i 's/IPv4/IPv6/g' /etc/xinetd.d/tftp
restorecon -r /tftpboot
setenforce 0
# maybe disable selinux altogether by setting it to "disabled" in /etc/selinux/conf

#start and enable tftp related services rhel 7
#systemctl start xinetd.service
#systemctl enable xinetd.service

#start and enable tftp related services rhel 6
service xinetd start
chkconfig xinetd on

#install tcpdump
yum -y install tcpdump

#start and enable web server
service httpd start
chkconfig httpd on

#copy all necessary files to host
rsync -Pravdtze ssh /VirtualMachines/backups/imp1* root@imp1:/home/ralongi




