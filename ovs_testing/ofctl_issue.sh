
rm -f /tmp/junk.txt
wget -O /tmp/junk.txt http://netqe-infra01.knqe.lab.eng.bos.redhat.com/packages/junk.txt
password=$(cat /tmp/junk.txt)

update_infra01_repo()
{
	ovs_target=$1
	file_server="netqe-infra01.knqe.lab.eng.bos.redhat.com"
	if [[ ! -e /etc/yum.repos.d/infra01-server.repo ]]; then
		wget -O /etc/yum.repos.d/infra01-server.repo http://netqe-infra01.knqe.lab.eng.bos.redhat.com/packages/infra01-server.repo
	fi
	rm -f /tmp/yum*

	if [[ $ovs_target == "2.4.1" ]] || [[ $ovs_target == "2.4.1.1" ]]; then
		ovs_target="openvswitch-2.4.1-1.git20160628.el7fdp.x86_64.rpm"
		ovs_rpm_location="2.4.1/1.git20160628.el7fdp"
	elif [[ $ovs_target == "2.5.0.14" ]]; then
		ovs_target="openvswitch-2.5.0-14.git20160727.el7fdp.x86_64.rpm"
		ovs_rpm_location="2.5.0/14.git20160727.el7fdp"
	elif [[ $ovs_target == "2.5.0.22" ]]; then
		ovs_target="openvswitch-2.5.0-22.git20160727.el7fdp.x86_64.rpm"
		ovs_rpm_location="2.5.0/22.git20160727.el7fdp"
	elif [[ $ovs_target == "2.6.1" ]]; then
		ovs_target="openvswitch-2.6.1-3.git20161206.el7fdb.x86_64.rpm"
		ovs_rpm_location="2.6.1/3.git20161206.el7fdb"
	elif [[ $ovs_target == "2.5.0.23" ]]; then
		ovs_target="openvswitch-2.5.0-22.git20160727.el7fdp.bz1403958.fbl.2.x86_64.rpm"
	else
		echo "No valid OVS target version was specified."
		exit 0
	fi

	if [[ $ovs_target == "openvswitch-2.5.0-22.git20160727.el7fdp.bz1403958.fbl.2.x86_64.rpm" ]]; then
		sshpass -p $password ssh root@$file_server "rm -f /home/www/html/repo/packages/openvswitch*.rpm && wget -q -O /home/www/html/repo/packages/$ovs_target http://file.bos.redhat.com/~fleitner/bz1403958/$ovs_target && createrepo --update /home/www/html/repo/"
	else
		sshpass -p $password ssh root@$file_server "rm -f /home/www/html/repo/packages/openvswitch*.rpm && wget -q -O /home/www/html/repo/packages/$ovs_target http://download-node-02.eng.bos.redhat.com/brewroot/packages/openvswitch/$ovs_rpm_location/x86_64/$ovs_target && createrepo --update /home/www/html/repo/"
	fi

	yum clean all expire-cache
	yum provides openvswitch
}

change_ovs()
{
	yum -y remove openvswitch
	yum -y install openvswitch
	local current_ovs_ver=$(rpm -q openvswitch)".rpm"
	if [[ $current_ovs_ver == $ovs_target ]]; then
		echo "OVS version change was SUCCESSFUL."
	else
		echo "OVS version change was UNSUCCESSFUL."
	fi
}

update_infra01_repo 2.5.0.14
change_ovs

systemctl enable openvswitch.service
systemctl start openvswitch.service
sleep 4
systemctl is-enabled openvswitch.service | grep -iw enabled
systemctl is-enabled ovs-vswitchd.service | grep -iw static
systemctl is-enabled ovsdb-server.service | grep -iw static
ovs-vsctl --if-exists del-br ovsbr0
ovs-vsctl add-br ovsbr0
ovs-vsctl --if-exists del-port eno49
ovs-vsctl add-port ovsbr0 eno49
ovs-vsctl --if-exists del-port intport0
ovs-vsctl add-port ovsbr0 intport0 -- set interface intport0 type=internal
ip link set dev eno49 up
ip link set dev intport0 up
ovs-ofctl add-flow ovsbr0 idle_timeout=180,priority=33000,in_port=1,actions=output:2
ovs-ofctl add-flow ovsbr0 idle_timeout=180,priority=33000,in_port=2,actions=output:1
sleep 4
ovs-vsctl show | grep ovsbr0
ovs-vsctl show | grep eno49
ovs-vsctl show | grep intport0

ovs-ofctl dump-flows ovsbr0 | grep actions=output:2
ovs-ofctl dump-flows ovsbr0 | grep actions=output:1

update_infra01_repo 2.5.0.23

yum -y update openvswitch

ovs-ofctl dump-flows ovsbr0 | grep actions=output:2
ovs-ofctl dump-flows ovsbr0 | grep actions=output:1

