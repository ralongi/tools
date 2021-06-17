#!/bin/bash

# NOTE: chelsio1 is already a stable system for FDP RHEL-7, chelsio2 for RHEL-8

# To build stable system for RHEL7 ppc64le:

# NOTE: For repo "rhel-7-for-power9-fast-datapath-rpms", use test profile "stable-rhel-alt-7-server"

echo ""
echo "Creating ppc64le stable system for FDP RHEL-7..."
echo ""

bkr workflow-tomorrow --hostrequire=hostlabcontroller=lab-02.rhts.eng.rdu.redhat.com --stable-system --taskparam OATS_TPS_STABLE=true --profile=fast-datapath-for-rhel-7-rpms --arch=ppc64le --task "! yum -y install http://download.eng.bos.redhat.com/brewroot/vol/rhel-7/packages/python-twisted-web/12.1.0/5.el7_2/ppc64le/python-twisted-web-12.1.0-5.el7_2.ppc64le.rpm http://download.eng.bos.redhat.com/brewroot/vol/rhel-7/packages/python-twisted-core/12.2.0/4.el7/ppc64le/python-twisted-core-12.2.0-4.el7.ppc64le.rpm http://download.eng.bos.redhat.com/brewroot/vol/rhel-7/packages/python-zope-interface/4.0.5/4.el7/ppc64le/python-zope-interface-4.0.5-4.el7.ppc64le.rpm http://download.eng.bos.redhat.com/brewroot/vol/rhel-7/packages/SOAPpy/0.11.6/17.el7/noarch/SOAPpy-0.11.6-17.el7.noarch.rpm http://download.eng.bos.redhat.com/brewroot/vol/rhel-7/packages/python-fpconst/0.7.3/12.el7/noarch/python-fpconst-0.7.3-12.el7.noarch.rpm http://download-node-02.eng.bos.redhat.com/brewroot/packages/container-selinux/2.77/1.el7_6/noarch/container-selinux-2.77-1.el7_6.noarch.rpm tcpdump python-netifaces libibverbs python3" --task "! /bin/cp -f /etc/tpsd.conf /etc/tpsd.conf_orig" --task '! wget -O /etc/tpsd.conf http://netqe-infra01.knqe.lab.eng.bos.redhat.com/misc/tpsd.conf' --task "! systemctl restart tpsd"

# Note: use test profile "stable-rhel-alt-7-server" with above ppc64le command for RHEL ALT streams.

# To build stable system for RHEL7 s390x:

echo ""
echo "Creating s390x stable system for FDP RHEL-7..."
echo ""

bkr workflow-tomorrow --hostrequire=hostlabcontroller=lab-02.rhts.eng.bos.redhat.com --stable-system --taskparam OATS_TPS_STABLE=true --profile=fast-datapath-for-rhel-7-rpms --arch=s390x --task "! yum -y install http://download.eng.bos.redhat.com/brewroot/vol/rhel-7/packages/python-twisted-web/12.1.0/5.el7_2/s390x/python-twisted-web-12.1.0-5.el7_2.s390x.rpm http://download.eng.bos.redhat.com/brewroot/vol/rhel-7/packages/python-twisted-core/12.2.0/4.el7/s390x/python-twisted-core-12.2.0-4.el7.s390x.rpm http://download.eng.bos.redhat.com/brewroot/vol/rhel-7/packages/python-zope-interface/4.0.5/4.el7/s390x/python-zope-interface-4.0.5-4.el7.s390x.rpm http://download.eng.bos.redhat.com/brewroot/vol/rhel-7/packages/SOAPpy/0.11.6/17.el7/noarch/SOAPpy-0.11.6-17.el7.noarch.rpm http://download.eng.bos.redhat.com/brewroot/vol/rhel-7/packages/python-fpconst/0.7.3/12.el7/noarch/python-fpconst-0.7.3-12.el7.noarch.rpm http://download-node-02.eng.bos.redhat.com/brewroot/packages/container-selinux/2.77/1.el7_6/noarch/container-selinux-2.77-1.el7_6.noarch.rpm tcpdump python-netifaces libibverbs python3" --task "! /bin/cp -f /etc/tpsd.conf /etc/tpsd.conf_orig" --task '! wget -O /etc/tpsd.conf http://netqe-infra01.knqe.lab.eng.bos.redhat.com/misc/tpsd.conf' --task "! systemctl restart tpsd"

# To build stable system for RHEL8 ppc64le

echo ""
echo "Creating ppc64le stable system for FDP RHEL-8..."
echo ""

bkr workflow-tomorrow --split-buildroot --hostrequire=hostlabcontroller=lab-02.rhts.eng.rdu.redhat.com --stable-system --taskparam OATS_TPS_STABLE=true --profile=fast-datapath-for-rhel-8-rpms --arch=ppc64le --variant=BaseOS --task "! dnf -y install openvswitch-selinux-extra-policy tcpdump network-scripts libatomic" --task "! /bin/cp -f /etc/tpsd.conf /etc/tpsd.conf_orig" --task '! wget -O /etc/tpsd.conf http://netqe-infra01.knqe.lab.eng.bos.redhat.com/misc/tpsd.conf' --task '! systemctl restart tpsd' --task "! dnf -y install libibverbs"

# To build stable system for RHEL8 s390x

echo ""
echo "Creating s390x stable system for FDP RHEL-8..."
echo ""

bkr workflow-tomorrow --split-buildroot --hostrequire=hostlabcontroller=lab-02.rhts.eng.bos.redhat.com --stable-system --taskparam OATS_TPS_STABLE=true --profile=fast-datapath-for-rhel-8-rpms --arch=s390x --variant=BaseOS --task "! dnf -y install openvswitch-selinux-extra-policy tcpdump network-scripts libatomic" --task "! /bin/cp -f /etc/tpsd.conf /etc/tpsd.conf_orig" --task '! wget -O /etc/tpsd.conf http://netqe-infra01.knqe.lab.eng.bos.redhat.com/misc/tpsd.conf' --task "! systemctl restart tpsd" --task "! dnf -y install libibverbs"
