#!/bin/bash

RPM_CONTAINER_SELINUX_POLICY="http://download.devel.redhat.com/brewroot/packages/container-selinux/2.77/1.el7_6/noarch/container-selinux-2.77-1.el7_6.noarch.rpm"

while [ 1 ]; do
	if [[ ! $(tps-status | grep idle) ]] || [[ $(pgrep yum) ]]; then
		echo "TPS not idle and/or yum lock in place.  Sleeping 30 seconds..."
		sleep 30
	else
		for i in $(rpm -qa | grep ovn); do yum -y remove $i; done
		for i in $(rpm -qa | grep openvswitch | grep -v selinux); do yum -y remove $i; done
		
		echo "Installed openvswitch packages:"
		echo "$(rpm -qa | grep openvswitch | grep -v selinux)"
		echo "Installed ovn packages:"
		echo "$(rpm -qa | grep ovn)"

		if [ $(uname -m) == "x86_64" ]; then
			yum -y install http://download.eng.bos.redhat.com/brewroot/vol/rhel-7/packages/python-twisted-web/12.1.0/5.el7_2/x86_64/python-twisted-web-12.1.0-5.el7_2.x86_64.rpm http://download.eng.bos.redhat.com/brewroot/vol/rhel-7/packages/python-twisted-core/12.2.0/4.el7/x86_64/python-twisted-core-12.2.0-4.el7.x86_64.rpm http://download.eng.bos.redhat.com/brewroot/vol/rhel-7/packages/python-zope-interface/4.0.5/4.el7/x86_64/python-zope-interface-4.0.5-4.el7.x86_64.rpm http://download.eng.bos.redhat.com/brewroot/vol/rhel-7/packages/SOAPpy/0.11.6/17.el7/noarch/SOAPpy-0.11.6-17.el7.noarch.rpm http://download.eng.bos.redhat.com/brewroot/vol/rhel-7/packages/python-fpconst/0.7.3/12.el7/noarch/python-fpconst-0.7.3-12.el7.noarch.rpm
	
		elif [ $(uname -m) == "ppc64le" ]; then

			yum -y install http://download.eng.bos.redhat.com/brewroot/vol/rhel-7/packages/python-twisted-web/12.1.0/5.el7_2/ppc64le/python-twisted-web-12.1.0-5.el7_2.ppc64le.rpm http://download.eng.bos.redhat.com/brewroot/vol/rhel-7/packages/python-twisted-core/12.2.0/4.el7/ppc64le/python-twisted-core-12.2.0-4.el7.ppc64le.rpm http://download.eng.bos.redhat.com/brewroot/vol/rhel-7/packages/python-zope-interface/4.0.5/4.el7/ppc64le/python-zope-interface-4.0.5-4.el7.ppc64le.rpm http://download.eng.bos.redhat.com/brewroot/vol/rhel-7/packages/SOAPpy/0.11.6/17.el7/noarch/SOAPpy-0.11.6-17.el7.noarch.rpm http://download.eng.bos.redhat.com/brewroot/vol/rhel-7/packages/python-fpconst/0.7.3/12.el7/noarch/python-fpconst-0.7.3-12.el7.noarch.rpm
		fi

	yum -y install tcpdump
	yum -y install python-netifaces
	yum -y install libibverbs
	yum -y install $RPM_CONTAINER_SELINUX_POLICY
	fi
	break
done

