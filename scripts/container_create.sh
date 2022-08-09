# Provision a system using the target arch (i.e. ppc64le)
# Execute the following commands on the target system:
sudo yum -y install wget
sudo yum -y install container-tools
sudo yum -y install podman

# For RHEL-9 Beta:
sudo wget -O /etc/pki/rpm-gpg/RPM-GPG-KEY-redhat-beta https://www.redhat.com/security/data/f21541eb.txt
    
# RHEL-9 Beta:
sudo podman image trust set -f /etc/pki/rpm-gpg/RPM-GPG-KEY-redhat-beta registry.access.redhat.com/ubi9-beta
    
- Create a docker file on the target system (i.e. dockerfile.ubi9, dockerfile.ubi8) using the exact content below:

# RHEL-9.0 Beta:
From registry.access.redhat.com/ubi9-beta/ubi
RUN printf '[beaker-AppStream]\nname=beaker-AppStream\nbaseurl=http://download.eng.bos.redhat.com/rhel-9/rel-eng/RHEL-9/latest-RHEL-9.0/compose/AppStream/$basearch/os/\nenabled=1\ngpgcheck=0' > /etc/yum.repos.d/beaker-AppStream.repo
RUN printf '[beaker-BaseOS]\nname=beaker-BaseOS\nbaseurl=http://download.eng.bos.redhat.com/rhel-9/rel-eng/RHEL-9/latest-RHEL-9.0/compose/BaseOS/$basearch/os/\nenabled=1\ngpgcheck=0' > /etc/yum.repos.d/beaker-BaseOS.repo
RUN printf '[infra01-server]\nname=infra01-server\nbaseurl=http://netqe-infra01.knqe.lab.eng.bos.redhat.com/repo\nenabled=1\ngpgcheck=0' > /etc/yum.repos.d/infra01-server.repo
RUN yum -y install iproute iputils procps-ng netperf-2.7.0-2.20210803git3bc455b.el9 automake
CMD ["sleep", "infinity"]

# RHEL-9.0 GA:
From registry.access.redhat.com/ubi9/ubi
RUN printf '[beaker-AppStream]\nname=beaker-AppStream\nbaseurl=http://download.eng.rdu.redhat.com/released/RHEL-9/9.0.0/AppStream/$basearch/os/\nenabled=1\ngpgcheck=0' > /etc/yum.repos.d/beaker-AppStream.repo
RUN printf '[beaker-BaseOS]\nname=beaker-BaseOS\nbaseurl=http://download.eng.rdu.redhat.com/released/RHEL-9/9.0.0/BaseOS/$basearch/os/\nenabled=1\ngpgcheck=0' > /etc/yum.repos.d/beaker-BaseOS.repo
RUN printf '[infra01-server]\nname=infra01-server\nbaseurl=http://netqe-infra01.knqe.lab.eng.bos.redhat.com/repo\nenabled=1\ngpgcheck=0' > /etc/yum.repos.d/infra01-server.repo
RUN yum -y install iproute iputils procps-ng netperf-2.7.0-2.20210803git3bc455b.el9 automake
CMD ["sleep", "infinity"]

# RHEL-8.6 GA:
From registry.access.redhat.com/ubi8/ubi
RUN printf '[beaker-AppStream]\nname=beaker-AppStream\nbaseurl=http://download.eng.rdu.redhat.com/released/rhel-6-7-8/rhel-8/RHEL-8/8.6.0/AppStream/$basearch/os/\nenabled=1\ngpgcheck=0' > /etc/yum.repos.d/beaker-AppStream.repo
RUN printf '[beaker-BaseOS]\nname=beaker-BaseOS\nbaseurl=http://download.eng.rdu.redhat.com/released/rhel-6-7-8/rhel-8/RHEL-8/8.6.0/BaseOS/$basearch/os/\nenabled=1\ngpgcheck=0' > /etc/yum.repos.d/beaker-BaseOS.repo
RUN printf '[infra01-server]\nname=infra01-server\nbaseurl=http://netqe-infra01.knqe.lab.eng.bos.redhat.com/repo\nenabled=1\ngpgcheck=0' > /etc/yum.repos.d/infra01-server.repo
RUN yum -y install iproute iputils procps-ng netperf-2.7.0-1.20210803git3bc455b.el8 automake
CMD ["sleep", "infinity"]

# Build the image on the target system via the following command on the target system (example below uses docker file dockerfile.ubi9:
podman build -f dockerfile.ubi9 . | tee build.txt

# Save the image on the target system using the commands below:
image_id=$(tail -n1 build.txt)
podman save $image_id -o ~/rhel9.0_$(uname -m)

# To test integrity of newly created image on target system:
   
podman load --input  rhel9.0_$(uname -m) | tee podman_load.txt
image=$(awk -F ":" '{print $3}' podman_load.txt | tr -d " ")
podman run -dt --name=container1 $image
podman exec container1 uname -m
podman exec container1 cat /etc/os-release
podman exec container1 ip -V
podman exec container1 ping -V
podman exec container1 netperf -V
podman exec container1 pgrep -V
podman exec container1 pkill -V
podman exec container1 rpm -q automake

scp rhel9.0_$(uname -m) root@netqe-infra01.knqe.lab.eng.bos.redhat.com:/home/www/html/container_images

podman stop container1
podman rm container1
images=$(podman images | awk '{print $3}'| tr -d 'IMAGE')
for i in $images; do podman rmi -f $i; done
    
