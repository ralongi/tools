#!/bin/bash

# To build stable system for RHEL7 x86_64

RHEL_VERSION=$1

if [[ $# -lt 1 ]]; then
	echo "Please provide the RHEL major version."
	echo "Example: $0 7 or $0 8"
fi

if [[ $RHEL_VERSION -eq 7 ]]; then
	bkr workflow-tomorrow 7 --hostrequire=hostlabcontroller=lab-02.rhts.eng.rdu.redhat.com --stable-system --taskparam OATS_TPS_STABLE=true --profile=fast-datapath-for-rhel-7-rpms --arch=x86_64 --task "! yum -y install http://download.eng.bos.redhat.com/brewroot/vol/rhel-7/packages/python-twisted-web/12.1.0/5.el7_2/x86_64/python-twisted-web-12.1.0-5.el7_2.x86_64.rpm http://download.eng.bos.redhat.com/brewroot/vol/rhel-7/packages/python-twisted-core/12.2.0/4.el7/x86_64/python-twisted-core-12.2.0-4.el7.x86_64.rpm http://download.eng.bos.redhat.com/brewroot/vol/rhel-7/packages/python-zope-interface/4.0.5/4.el7/x86_64/python-zope-interface-4.0.5-4.el7.x86_64.rpm http://download.eng.bos.redhat.com/brewroot/vol/rhel-7/packages/SOAPpy/0.11.6/17.el7/noarch/SOAPpy-0.11.6-17.el7.noarch.rpm http://download.eng.bos.redhat.com/brewroot/vol/rhel-7/packages/python-fpconst/0.7.3/12.el7/noarch/python-fpconst-0.7.3-12.el7.noarch.rpm http://download-node-02.eng.bos.redhat.com/brewroot/packages/container-selinux/2.77/1.el7_6/noarch/container-selinux-2.77-1.el7_6.noarch.rpm tcpdump python-netifaces libibverbs python3" --task "! /bin/cp -f /etc/tpsd.conf /etc/tpsd.conf_orig" --task "! wget -O /etc/tpsd.conf http://netqe-infra01.knqe.lab.eng.bos.redhat.com/misc/tpsd.conf" --task "! mount -a -t nfs" --task "! systemctl restart tpsd" --task "! wget -O ~/stable_cleanup.sh http://netqe-infra01.knqe.lab.eng.bos.redhat.com/share/ralongi/stable_cleanup.sh; chmod +x ~/stable_cleanup.sh"

	# To build stable system for RHEL7 ppc64le:

	# NOTE: For repo "rhel-7-for-power9-fast-datapath-rpms", use test profile "stable-rhel-alt-7-server"

	bkr workflow-tomorrow 7 --hostrequire=hostlabcontroller=lab-02.rhts.eng.rdu.redhat.com --stable-system --taskparam OATS_TPS_STABLE=true --profile=fast-datapath-for-rhel-7-rpms --arch=ppc64le --task "! yum -y install http://download.eng.bos.redhat.com/brewroot/vol/rhel-7/packages/python-twisted-web/12.1.0/5.el7_2/ppc64le/python-twisted-web-12.1.0-5.el7_2.ppc64le.rpm http://download.eng.bos.redhat.com/brewroot/vol/rhel-7/packages/python-twisted-core/12.2.0/4.el7/ppc64le/python-twisted-core-12.2.0-4.el7.ppc64le.rpm http://download.eng.bos.redhat.com/brewroot/vol/rhel-7/packages/python-zope-interface/4.0.5/4.el7/ppc64le/python-zope-interface-4.0.5-4.el7.ppc64le.rpm http://download.eng.bos.redhat.com/brewroot/vol/rhel-7/packages/SOAPpy/0.11.6/17.el7/noarch/SOAPpy-0.11.6-17.el7.noarch.rpm http://download.eng.bos.redhat.com/brewroot/vol/rhel-7/packages/python-fpconst/0.7.3/12.el7/noarch/python-fpconst-0.7.3-12.el7.noarch.rpm http://download-node-02.eng.bos.redhat.com/brewroot/packages/container-selinux/2.77/1.el7_6/noarch/container-selinux-2.77-1.el7_6.noarch.rpm tcpdump python-netifaces libibverbs python3" --task "! /bin/cp -f /etc/tpsd.conf /etc/tpsd.conf_orig" --task "! wget -O /etc/tpsd.conf http://netqe-infra01.knqe.lab.eng.bos.redhat.com/misc/tpsd.conf" --task "! mount -a -t nfs" --task "! systemctl restart tpsd" --task "! wget -O ~/stable_cleanup.sh http://netqe-infra01.knqe.lab.eng.bos.redhat.com/share/ralongi/stable_cleanup.sh; chmod +x ~/stable_cleanup.sh"

	# Note: use test profile "stable-rhel-alt-7-server" with above ppc64le command for RHEL ALT streams.

	# To build stable system for RHEL7 s390x:

	bkr workflow-tomorrow 7 --hostrequire=hostlabcontroller=lab-02.rhts.eng.bos.redhat.com --stable-system --taskparam OATS_TPS_STABLE=true --profile=fast-datapath-for-rhel-7-rpms --arch=s390x --task "! yum -y install http://download.eng.bos.redhat.com/brewroot/vol/rhel-7/packages/python-twisted-web/12.1.0/5.el7_2/s390x/python-twisted-web-12.1.0-5.el7_2.s390x.rpm http://download.eng.bos.redhat.com/brewroot/vol/rhel-7/packages/python-twisted-core/12.2.0/4.el7/s390x/python-twisted-core-12.2.0-4.el7.s390x.rpm http://download.eng.bos.redhat.com/brewroot/vol/rhel-7/packages/python-zope-interface/4.0.5/4.el7/s390x/python-zope-interface-4.0.5-4.el7.s390x.rpm http://download.eng.bos.redhat.com/brewroot/vol/rhel-7/packages/SOAPpy/0.11.6/17.el7/noarch/SOAPpy-0.11.6-17.el7.noarch.rpm http://download.eng.bos.redhat.com/brewroot/vol/rhel-7/packages/python-fpconst/0.7.3/12.el7/noarch/python-fpconst-0.7.3-12.el7.noarch.rpm http://download-node-02.eng.bos.redhat.com/brewroot/packages/container-selinux/2.77/1.el7_6/noarch/container-selinux-2.77-1.el7_6.noarch.rpm tcpdump python-netifaces libibverbs python3" --task "! /bin/cp -f /etc/tpsd.conf /etc/tpsd.conf_orig" --task "! wget -O /etc/tpsd.conf http://netqe-infra01.knqe.lab.eng.bos.redhat.com/misc/tpsd.conf" --task "! mount -a -t nfs" --task "! systemctl restart tpsd" --task "! wget -O ~/stable_cleanup.sh http://netqe-infra01.knqe.lab.eng.bos.redhat.com/share/ralongi/stable_cleanup.sh; chmod +x ~/stable_cleanup.sh"
	
	# To build stable system for RHEL7 aarch64:
		
	bkr workflow-tomorrow 7 --stable-system --taskparam OATS_TPS_STABLE=true --profile=fast-datapath-for-rhel-7-rpms --arch=aarch64 --task "! yum -y install http://download.eng.bos.redhat.com/brewroot/vol/rhel-7/packages/python-twisted-web/12.1.0/5.el7_2/aarch64/python-twisted-web-12.1.0-5.el7_2.aarch64.rpm http://download.eng.bos.redhat.com/brewroot/vol/rhel-7/packages/python-twisted-core/12.2.0/4.el7/aarch64/python-twisted-core-12.2.0-4.el7.aarch64.rpm http://download.eng.bos.redhat.com/brewroot/vol/rhel-7/packages/python-zope-interface/4.0.5/4.el7/aarch64/python-zope-interface-4.0.5-4.el7.aarch64.rpm http://download.eng.bos.redhat.com/brewroot/vol/rhel-7/packages/SOAPpy/0.11.6/17.el7/noarch/SOAPpy-0.11.6-17.el7.noarch.rpm http://download.eng.bos.redhat.com/brewroot/vol/rhel-7/packages/python-fpconst/0.7.3/12.el7/noarch/python-fpconst-0.7.3-12.el7.noarch.rpm http://download-node-02.eng.bos.redhat.com/brewroot/packages/container-selinux/2.77/1.el7_6/noarch/container-selinux-2.77-1.el7_6.noarch.rpm tcpdump python-netifaces libibverbs python3" --task "! /bin/cp -f /etc/tpsd.conf /etc/tpsd.conf_orig" --task "! wget -O /etc/tpsd.conf http://netqe-infra01.knqe.lab.eng.bos.redhat.com/misc/tpsd.conf" --task "! mount -a -t nfs" --task "! systemctl restart tpsd" --task "! wget -O ~/stable_cleanup.sh http://netqe-infra01.knqe.lab.eng.bos.redhat.com/share/ralongi/stable_cleanup.sh; chmod +x ~/stable_cleanup.sh"

fi

if [[ $RHEL_VERSION -eq 8 ]]; then
	# To build stable system for RHEL8 x86_64

	bkr workflow-tomorrow 8 --split-buildroot --hostrequire=hostlabcontroller=lab-02.rhts.eng.rdu.redhat.com --stable-system --taskparam OATS_TPS_STABLE=true --profile=fast-datapath-for-rhel-8-rpms --arch=x86_64 --variant=BaseOS --task "! dnf -y install openvswitch-selinux-extra-policy tcpdump network-scripts libatomic" --task "! /bin/cp -f /etc/tpsd.conf /etc/tpsd.conf_orig" --task "! wget -O /etc/tpsd.conf http://netqe-infra01.knqe.lab.eng.bos.redhat.com/misc/tpsd.conf" --task "! mount -a -t nfs" --task "! systemctl restart tpsd" --task "! dnf -y install libibverbs" --task "! wget -O ~/stable_cleanup.sh http://netqe-infra01.knqe.lab.eng.bos.redhat.com/share/ralongi/stable_cleanup.sh; chmod +x ~/stable_cleanup.sh"

	# To build stable system for RHEL8 ppc64le

	bkr workflow-tomorrow 8 --split-buildroot --hostrequire=hostlabcontroller=lab-02.rhts.eng.rdu.redhat.com --stable-system --taskparam OATS_TPS_STABLE=true --profile=fast-datapath-for-rhel-8-rpms --arch=ppc64le --variant=BaseOS --task "! dnf -y install openvswitch-selinux-extra-policy tcpdump network-scripts libatomic" --task "! /bin/cp -f /etc/tpsd.conf /etc/tpsd.conf_orig" --task "! wget -O /etc/tpsd.conf http://netqe-infra01.knqe.lab.eng.bos.redhat.com/misc/tpsd.conf" --task "! mount -a -t nfs" --task "! systemctl restart tpsd" --task "! dnf -y install libibverbs" --task "! wget -O ~/stable_cleanup.sh http://netqe-infra01.knqe.lab.eng.bos.redhat.com/share/ralongi/stable_cleanup.sh; chmod +x ~/stable_cleanup.sh"

	# To build stable system for RHEL8 s390x

	bkr workflow-tomorrow 8 --split-buildroot --hostrequire=hostlabcontroller=lab-02.rhts.eng.bos.redhat.com --stable-system --taskparam OATS_TPS_STABLE=true --profile=fast-datapath-for-rhel-8-rpms --arch=s390x --variant=BaseOS --task "! dnf -y install openvswitch-selinux-extra-policy tcpdump network-scripts libatomic" --task "! /bin/cp -f /etc/tpsd.conf /etc/tpsd.conf_orig" --task "! wget -O /etc/tpsd.conf http://netqe-infra01.knqe.lab.eng.bos.redhat.com/misc/tpsd.conf" --task "! mount -a -t nfs" --task "! systemctl restart tpsd" --task "! dnf -y install libibverbs" --task "! wget -O ~/stable_cleanup.sh http://netqe-infra01.knqe.lab.eng.bos.redhat.com/share/ralongi/stable_cleanup.sh; chmod +x ~/stable_cleanup.sh"
	
	# To build stable system for RHEL8 aarch64

	bkr workflow-tomorrow 8 --split-buildroot --stable-system --taskparam OATS_TPS_STABLE=true --profile=fast-datapath-for-rhel-8-rpms --arch=aarch64 --variant=BaseOS --task "! dnf -y install openvswitch-selinux-extra-policy tcpdump network-scripts libatomic" --task "! /bin/cp -f /etc/tpsd.conf /etc/tpsd.conf_orig" --task "! wget -O /etc/tpsd.conf http://netqe-infra01.knqe.lab.eng.bos.redhat.com/misc/tpsd.conf" --task "! mount -a -t nfs" --task "! systemctl restart tpsd" --task "! dnf -y install libibverbs" --task "! wget -O ~/stable_cleanup.sh http://netqe-infra01.knqe.lab.eng.bos.redhat.com/share/ralongi/stable_cleanup.sh; chmod +x ~/stable_cleanup.sh"	

fi

if [[ $RHEL_VERSION -eq 9 ]]; then
	# To build stable system for RHEL9 x86_64

	bkr workflow-tomorrow 9 --split-buildroot --hostrequire=hostlabcontroller=lab-02.rhts.eng.rdu.redhat.com --stable-system --taskparam OATS_TPS_STABLE=true --profile=fast-datapath-for-rhel-9-rpms --arch=x86_64 --variant=BaseOS --task "! dnf -y install openvswitch-selinux-extra-policy tcpdump libatomic" --task "! /bin/cp -f /etc/tpsd.conf /etc/tpsd.conf_orig" --task "! wget -O /etc/tpsd.conf http://netqe-infra01.knqe.lab.eng.bos.redhat.com/misc/tpsd.conf" --task "! systemctl restart tpsd" --task "! dnf -y install wget; wget -O ~/rhel9_packages.sh http://netqe-infra01.knqe.lab.eng.bos.redhat.com/share/ralongi/rhel9_packages.sh; chmod +x ~/rhel9_packages.sh; ~/rhel9_packages.sh" --task "! wget -O ~/stable_cleanup.sh http://netqe-infra01.knqe.lab.eng.bos.redhat.com/share/ralongi/stable_cleanup.sh; chmod +x ~/stable_cleanup.sh"

	# To build stable system for RHEL9 ppc64le

	bkr workflow-tomorrow 9 --split-buildroot --hostrequire=hostlabcontroller=lab-02.rhts.eng.rdu.redhat.com --stable-system --taskparam OATS_TPS_STABLE=true --profile=fast-datapath-for-rhel-9-rpms --arch=ppc64le --variant=BaseOS --task "! dnf -y install openvswitch-selinux-extra-policy tcpdump libatomic" --task "! /bin/cp -f /etc/tpsd.conf /etc/tpsd.conf_orig" --task "! wget -O /etc/tpsd.conf http://netqe-infra01.knqe.lab.eng.bos.redhat.com/misc/tpsd.conf" --task "! systemctl restart tpsd" --task "! dnf -y install wget; wget -O ~/rhel9_packages.sh http://netqe-infra01.knqe.lab.eng.bos.redhat.com/share/ralongi/rhel9_packages.sh; chmod +x ~/rhel9_packages.sh; ~/rhel9_packages.sh" --task "! wget -O ~/stable_cleanup.sh http://netqe-infra01.knqe.lab.eng.bos.redhat.com/share/ralongi/stable_cleanup.sh; chmod +x ~/stable_cleanup.sh"

	# To build stable system for RHEL9 s390x

	bkr workflow-tomorrow 9 --split-buildroot --hostrequire=hostlabcontroller=lab-02.rhts.eng.rdu.redhat.com --stable-system --taskparam OATS_TPS_STABLE=true --profile=fast-datapath-for-rhel-9-rpms --arch=s390x --variant=BaseOS --task "! dnf -y install openvswitch-selinux-extra-policy tcpdump libatomic" --task "! /bin/cp -f /etc/tpsd.conf /etc/tpsd.conf_orig" --task "! wget -O /etc/tpsd.conf http://netqe-infra01.knqe.lab.eng.bos.redhat.com/misc/tpsd.conf" --task "! systemctl restart tpsd" --task "! dnf -y install wget; wget -O ~/rhel9_packages.sh http://netqe-infra01.knqe.lab.eng.bos.redhat.com/share/ralongi/rhel9_packages.sh; chmod +x ~/rhel9_packages.sh; ~/rhel9_packages.sh" --task "! wget -O ~/stable_cleanup.sh http://netqe-infra01.knqe.lab.eng.bos.redhat.com/share/ralongi/stable_cleanup.sh; chmod +x ~/stable_cleanup.sh"
	
	# To build stable system for RHEL9 aarch64

	bkr workflow-tomorrow 9 --split-buildroot --hostrequire=hostlabcontroller=lab-02.rhts.eng.rdu.redhat.com --stable-system --taskparam OATS_TPS_STABLE=true --profile=fast-datapath-for-rhel-9-rpms --arch=aarch64 --variant=BaseOS --task "! dnf -y install openvswitch-selinux-extra-policy tcpdump libatomic" --task "! /bin/cp -f /etc/tpsd.conf /etc/tpsd.conf_orig" --task "! wget -O /etc/tpsd.conf http://netqe-infra01.knqe.lab.eng.bos.redhat.com/misc/tpsd.conf" --task "! systemctl restart tpsd" --task "! dnf -y install wget; wget -O ~/rhel9_packages.sh http://netqe-infra01.knqe.lab.eng.bos.redhat.com/share/ralongi/rhel9_packages.sh; chmod +x ~/rhel9_packages.sh; ~/rhel9_packages.sh" --task "! wget -O ~/stable_cleanup.sh http://netqe-infra01.knqe.lab.eng.bos.redhat.com/share/ralongi/stable_cleanup.sh; chmod +x ~/stable_cleanup.sh"

fi
