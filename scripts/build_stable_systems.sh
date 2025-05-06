#!/bin/bash

dbg_flag=${dbg_flag:-"set +x"}
$dbg_flag
arch=${arch:-""}
machine=${machine:-""}

if [[ $machine ]]; then
    target_system="--machine=$machine"
else
    target_system="--hostrequire=hostlabcontroller=lab-02.rhts.eng.rdu.redhat.com"
fi

RHEL_VERSION=$1

if [[ $# -lt 1 ]]; then
	echo "Please provide the RHEL major version."
	echo "Example: $0 7 or $0 8 or $0 9 or $0 10"
fi

build_stable_rhel7()
{
	bkr workflow-tomorrow 7 $(echo $target_system) --stable-system --taskparam OATS_TPS_STABLE="true" --profile="fast-datapath-for-rhel-7-rpms" --arch=$arch --task "! yum -y install http://download.eng.bos.redhat.com/brewroot/vol/rhel-7/packages/python-twisted-web/12.1.0/5.el7_2/$arch/python-twisted-web-12.1.0-5.el7_2.$arch.rpm http://download.eng.bos.redhat.com/brewroot/vol/rhel-7/packages/python-twisted-core/12.2.0/4.el7/$arch/python-twisted-core-12.2.0-4.el7.$arch.rpm http://download.eng.bos.redhat.com/brewroot/vol/rhel-7/packages/python-zope-interface/4.0.5/4.el7/$arch/python-zope-interface-4.0.5-4.el7.$arch.rpm http://download.eng.bos.redhat.com/brewroot/vol/rhel-7/packages/SOAPpy/0.11.6/17.el7/noarch/SOAPpy-0.11.6-17.el7.noarch.rpm http://download.eng.bos.redhat.com/brewroot/vol/rhel-7/packages/python-fpconst/0.7.3/12.el7/noarch/python-fpconst-0.7.3-12.el7.noarch.rpm http://download.devel.redhat.com/brewroot/packages/container-selinux/2.77/1.el7_6/noarch/container-selinux-2.77-1.el7_6.noarch.rpm tcpdump python-netifaces libibverbs python3" --task "! mv /usr/local/bin/update-tpsd-settings /usr/local/bin/update-tpsd-settings_orig; wget -O /usr/local/bin/update-tpsd-settings http://netqe-infra01.knqe.eng.rdu2.dc.redhat.com/share/ralongi/update-tpsd-settings; chmod +x /usr/local/bin/update-tpsd-settings; sed -i 's/jbappplatform-/jbappplatform-,fast-datapath-for-rhel-,rhel-7-fast-datapath-,rhel-7-for-power-le-fast-datapath-,rhel-7-for-power9-fast-datapath-,rhel-7-for-system-z-fast-datapath-/g' /etc/tpsd.conf; echo 'export TPS_IGNORE_APPSTREAM=true' >> /etc/tpsd.conf; systemctl restart tpsd" --task "! systemctl restart tpsd" --task "! wget -O ~/tps_download_links.txt http://netqe-infra01.knqe.eng.rdu2.dc.redhat.com/share/ralongi/tps_download_links.txt; pushd ~; wget -i ~/tps_download_links.txt -P . -q --show-progress; chmod +x *.sh; popd; echo alias up='/mnt/qa/scratch/rbiba/tps-utils/tps-report-interactive' >> ~/.bashrc; yum -y install at; wget --no-check-certificate -O ~/stable_system_https.sh http://netqe-infra01.knqe.eng.rdu2.dc.redhat.com/share/ralongi/stable_system_https.sh; chmod +x ~/stable_system_https.sh; ~/stable_system_https.sh"
}

build_stable_rhel8()
{
	bkr workflow-tomorrow 8 --split-buildroot $(echo $target_system) --stable-system --taskparam OATS_TPS_STABLE="true" --profile="fast-datapath-for-rhel-8-rpms" --arch=$arch --variant=BaseOS --task "! dnf -y install openvswitch-selinux-extra-policy tcpdump network-scripts libatomic libibverbs libreswan bpftrace" --task "! mv /usr/local/bin/update-tpsd-settings /usr/local/bin/update-tpsd-settings_orig; wget -O /usr/local/bin/update-tpsd-settings http://netqe-infra01.knqe.eng.rdu2.dc.redhat.com/share/ralongi/update-tpsd-settings; chmod +x /usr/local/bin/update-tpsd-settings; sed -i 's/jbappplatform-/jbappplatform-,fast-datapath-for-rhel-8-/g' /etc/tpsd.conf; echo 'export TPS_IGNORE_APPSTREAM=true' >> /etc/tpsd.conf; systemctl restart tpsd" --task "! systemctl restart tpsd" --task "! wget -O ~/tps_download_links.txt http://netqe-infra01.knqe.eng.rdu2.dc.redhat.com/share/ralongi/tps_download_links.txt; pushd ~; wget -i ~/tps_download_links.txt -P . -q --show-progress; chmod +x *.sh; popd; echo alias up='/mnt/qa/scratch/rbiba/tps-utils/tps-report-interactive' >> ~/.bashrc; dnf -y install at; wget --no-check-certificate -O ~/stable_system_https.sh http://netqe-infra01.knqe.eng.rdu2.dc.redhat.com/share/ralongi/stable_system_https.sh; chmod +x ~/stable_system_https.sh; ~/stable_system_https.sh"
}

build_stable_rhel9()
{
	bkr workflow-tomorrow 9 --split-buildroot $(echo $target_system) --stable-system --taskparam OATS_TPS_STABLE="true" --profile="fast-datapath-for-rhel-9-rpms" --arch=$arch --variant=BaseOS --task "! dnf -y install openvswitch-selinux-extra-policy tcpdump libatomic libreswan bpftrace" --task "! dnf -y install wget; wget -O ~/tps_rhel9_packages.sh http://netqe-infra01.knqe.eng.rdu2.dc.redhat.com/share/ralongi/tps_rhel9_packages.sh; chmod +x ~/tps_rhel9_packages.sh; ~/tps_rhel9_packages.sh" --task "! mv /usr/local/bin/update-tpsd-settings /usr/local/bin/update-tpsd-settings_orig; wget -O /usr/local/bin/update-tpsd-settings http://netqe-infra01.knqe.eng.rdu2.dc.redhat.com/share/ralongi/update-tpsd-settings; chmod +x /usr/local/bin/update-tpsd-settings; sed -i 's/jbappplatform-/jbappplatform-,fast-datapath-for-rhel-9-/g' /etc/tpsd.conf; echo 'export TPS_IGNORE_APPSTREAM=true' >> /etc/tpsd.conf; systemctl restart tpsd" --task "! systemctl restart tpsd" --task "! wget -O ~/tps_download_links.txt http://netqe-infra01.knqe.eng.rdu2.dc.redhat.com/share/ralongi/tps_download_links.txt; pushd ~; wget -i ~/tps_download_links.txt -P . -q --show-progress; chmod +x *.sh; popd; echo alias up='/mnt/qa/scratch/rbiba/tps-utils/tps-report-interactive' >> ~/.bashrc; dnf -y install at; wget --no-check-certificate -O ~/stable_system_https.sh http://netqe-infra01.knqe.eng.rdu2.dc.redhat.com/share/ralongi/stable_system_https.sh; chmod +x ~/stable_system_https.sh; ~/stable_system_https.sh"
}

build_stable_rhel10()
{
	bkr workflow-tomorrow 10 --split-buildroot $(echo $target_system) --stable-system --taskparam OATS_TPS_STABLE="true" --profile="fast-datapath-for-rhel-10-rpms" --arch=$arch --variant=BaseOS --task "! dnf -y install wget; wget -O /etc/yum.repos.d/oats-busybox.repo http://nest.test.redhat.com/mnt/tpsdist/repos/oats-busybox.repo; dnf -y install http://nest.test.redhat.com/mnt/tpsdist/test/oats.noarch.rpm"  --task "! dnf -y install openvswitch-selinux-extra-policy tcpdump libatomic libreswan bpftrace" --task "! dnf -y install wget; wget -O ~/tps_rhel9_packages.sh http://netqe-infra01.knqe.eng.rdu2.dc.redhat.com/share/ralongi/tps_rhel9_packages.sh; chmod +x ~/tps_rhel9_packages.sh; ~/tps_rhel9_packages.sh" --task "! mv /usr/local/bin/update-tpsd-settings /usr/local/bin/update-tpsd-settings_orig; wget -O /usr/local/bin/update-tpsd-settings http://netqe-infra01.knqe.eng.rdu2.dc.redhat.com/share/ralongi/update-tpsd-settings; chmod +x /usr/local/bin/update-tpsd-settings; sed -i 's/jbappplatform-/jbappplatform-,fast-datapath-for-rhel-9-/g' /etc/tpsd.conf; echo 'export TPS_IGNORE_APPSTREAM=true' >> /etc/tpsd.conf; systemctl restart tpsd" --task "! systemctl restart tpsd" --task "! wget -O ~/tps_download_links.txt http://netqe-infra01.knqe.eng.rdu2.dc.redhat.com/share/ralongi/tps_download_links.txt; pushd ~; wget -i ~/tps_download_links.txt -P . -q --show-progress; chmod +x *.sh; popd; echo alias up='/mnt/qa/scratch/rbiba/tps-utils/tps-report-interactive' >> ~/.bashrc; dnf -y install at; wget --no-check-certificate -O ~/stable_system_https.sh http://netqe-infra01.knqe.eng.rdu2.dc.redhat.com/share/ralongi/stable_system_https.sh; chmod +x ~/stable_system_https.sh; ~/stable_system_https.sh"
	
#	bkr workflow-tomorrow --erratify 10 x86_64 --reserve --stable-system --taskparam OATS_TPS_STABLE="true" --profile="fast-datapath-for-rhel-10-rpms" --arch=$arch --variant=BaseOS --taskparam RPM_BASEURL=http://nest.test.redhat.com/mnt/tpsdist/test  --task "! dnf -y install openvswitch-selinux-extra-policy tcpdump libatomic libreswan bpftrace" --task "! dnf -y install wget; wget -O ~/tps_rhel9_packages.sh http://netqe-infra01.knqe.eng.rdu2.dc.redhat.com/share/ralongi/tps_rhel9_packages.sh; chmod +x ~/tps_rhel9_packages.sh; ~/tps_rhel9_packages.sh" --task "! mv /usr/local/bin/update-tpsd-settings /usr/local/bin/update-tpsd-settings_orig; wget -O /usr/local/bin/update-tpsd-settings http://netqe-infra01.knqe.eng.rdu2.dc.redhat.com/share/ralongi/update-tpsd-settings; chmod +x /usr/local/bin/update-tpsd-settings; sed -i 's/jbappplatform-/jbappplatform-,fast-datapath-for-rhel-9-/g' /etc/tpsd.conf; echo 'export TPS_IGNORE_APPSTREAM=true' >> /etc/tpsd.conf; systemctl restart tpsd" --task "! systemctl restart tpsd" --task "! wget -O ~/tps_download_links.txt http://netqe-infra01.knqe.eng.rdu2.dc.redhat.com/share/ralongi/tps_download_links.txt; pushd ~; wget -i ~/tps_download_links.txt -P . -q --show-progress; chmod +x *.sh; popd; echo alias up='/mnt/qa/scratch/rbiba/tps-utils/tps-report-interactive' >> ~/.bashrc; dnf -y install at; wget --no-check-certificate -O ~/stable_system_https.sh http://netqe-infra01.knqe.eng.rdu2.dc.redhat.com/share/ralongi/stable_system_https.sh; chmod +x ~/stable_system_https.sh; ~/stable_system_https.sh"
}

if [[ $RHEL_VERSION -eq 7 ]]; then
	if [[ $arch ]]; then
		build_stable_rhel7
	else
		arch=x86_64
		build_stable_rhel7
		
		arch=ppc64le
		build_stable_rhel7
		
		arch=aarch64
		build_stable_rhel7
		
		arch=s390x
		build_stable_rhel7
	fi
fi

if [[ $RHEL_VERSION -eq 8 ]]; then
	if [[ $arch ]]; then
		build_stable_rhel8
	else
		arch=x86_64
		build_stable_rhel8
		
		arch=ppc64le
		build_stable_rhel8
		
		arch=aarch64
		build_stable_rhel8
		
		arch=s390x
		build_stable_rhel8
	fi
fi

if [[ $RHEL_VERSION -eq 9 ]]; then
	if [[ $arch ]]; then
		build_stable_rhel9
	else
		arch=x86_64
		build_stable_rhel9
		
		arch=ppc64le
		build_stable_rhel9
		
		arch=aarch64
		build_stable_rhel9
		
		arch=s390x
		build_stable_rhel9
	fi
fi

if [[ $RHEL_VERSION -eq 10 ]]; then
	if [[ $arch ]]; then
		build_stable_rhel10
	else
		arch=x86_64
		build_stable_rhel10
		
		arch=ppc64le
		build_stable_rhel10
		
		arch=aarch64
		build_stable_rhel10
		
		arch=s390x
		build_stable_rhel10
	fi
fi
