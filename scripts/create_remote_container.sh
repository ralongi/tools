#!/bin/bash

$dbg_flag
skip_file_upload=${skip_file_upload:-"no"}
tmp0=$(mktemp)

# on remote system

rpm -q wget || sudo dnf -y install wget
rpm -q container-tools || sudo dnf -y install container-tools
rpm -q podman || sudo dnf -y install podman
rpm -q nfs-utils || sudo dnf -y install fs-utils

. /etc/os-release

arch=$(uname -m)
image_file=rhel"$VERSION_ID"_$(uname -m)
tmp_image_file="$image_file"_tmp
rm -rf "$image_file" "$tmp_image_file"
rm -rf /tmp/images
mkdir -p /tmp/images
pushd /tmp/images &>/dev/null

rhel_major_version=$(echo $VERSION_ID | awk -F "." '{print $1}')
appstream_baseurl=$(grep baseurl /etc/yum.repos.d/beaker-AppStream.repo | awk -F "=" '{print $2}')
baseos_baseurl=$(grep baseurl /etc/yum.repos.d/beaker-BaseOS.repo | awk -F "=" '{print $2}')

rm -f ContainerFile

if [[ $rhel_major_version -eq 8 ]]; then
	cat > ContainerFile <<-EOF
	FROM registry.access.redhat.com/ubi8/ubi:latest
	RUN printf '[beaker-AppStream]\nname=beaker-AppStream\nbaseurl=$appstream_baseurl\nenabled=1\ngpgcheck=0' > /etc/yum.repos.d/beaker-AppStream.repo
	RUN printf '[beaker-BaseOS]\nname=beaker-BaseOS\nbaseurl=$baseos_baseurl\nenabled=1\ngpgcheck=0' > /etc/yum.repos.d/beaker-BaseOS.repo
	RUN dnf -y install iproute iputils procps-ng automake $driverctl $RPM_DPDK $RPM_DPDK_TOOLS
	CMD ["sleep", "infinity"]
	EOF
elif [[ $rhel_major_version -eq 9 ]]; then
	cat > ContainerFile <<-EOF
	FROM registry.access.redhat.com/ubi9/ubi:latest
	RUN printf '[beaker-AppStream]\nname=beaker-AppStream\nbaseurl=$appstream_baseurl\nenabled=1\ngpgcheck=0' > /etc/yum.repos.d/beaker-AppStream.repo
	RUN printf '[beaker-BaseOS]\nname=beaker-BaseOS\nbaseurl=$baseos_baseurl\nenabled=1\ngpgcheck=0' > /etc/yum.repos.d/beaker-BaseOS.repo
	RUN dnf -y install iproute iputils procps-ng automake $driverctl $RPM_DPDK $RPM_DPDK_TOOLS
	CMD ["sleep", "infinity"]
	EOF
elif [[ $rhel_major_version -eq 10 ]]; then
	cat > ContainerFile <<-EOF
	FROM registry.access.redhat.com/ubi10/ubi:latest
	RUN printf '[beaker-AppStream]\nname=beaker-AppStream\nbaseurl=$appstream_baseurl\nenabled=1\ngpgcheck=0' > /etc/yum.repos.d/beaker-AppStream.repo
	RUN printf '[beaker-BaseOS]\nname=beaker-BaseOS\nbaseurl=$baseos_baseurl\nenabled=1\ngpgcheck=0' > /etc/yum.repos.d/beaker-BaseOS.repo
	RUN dnf -y install iproute iputils procps-ng automake $driverctl $RPM_DPDK $RPM_DPDK_TOOLS
	CMD ["sleep", "infinity"]
	EOF
fi	

podman build -f ContainerFile . | tee $tmp0
image_id=$(tail -n1 $tmp0)
podman save $image_id -o $tmp_image_file

# post creation tasks
podman load --input $tmp_image_file | tee $tmp0
image=$(awk -F ":" '{print $3}' $tmp0 | tr -d " ")
podman run -dt --name=container1 $image
podman exec container1 dnf -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-$rhel_major_version.noarch.rpm
podman exec container1 dnf -y install netperf
podman exec container1 dnf -y upgrade
wait
podman exec container1 reboot
sleep 30s

podman commit container1 | tee $tmp0
image_id=$(tail -n1 $tmp0)
podman save $image_id -o $image_file

# upload the image to the nfs server
if [[ $(hostname) =~ pek2.redhat.com ]]; then
	nfs_server=netqe-bj.usersys.redhat.com
	shared_home=/home/share/container_images
	web_nfs_url=http://netqe-bj.usersys.redhat.com/share/container_images
else
	nfs_server=netqe-infra01.knqe.eng.rdu2.dc.redhat.com
	shared_home=/home/www/html/share/container_images
	web_nfs_url=http://netqe-infra01.knqe.eng.rdu2.dc.redhat.com/share/container_images
fi

if [[ $skip_file_upload != "yes" ]]; then
	echo
	echo "Uploading $image_file to $nfs_server:$shared_home..."
	mnt_dir="/mnt/container_images"
	[[ ! -d ${mnt_dir} ]] && mkdir -p ${mnt_dir}
	sudo mount $nfs_server:$shared_home ${mnt_dir}
	sudo /bin/cp -f $image_file ${mnt_dir}
	sudo chmod 777 ${mnt_dir}/${image_file}
	sudo ls -l ${mnt_dir}/${image_file}
	sudo umount ${mnt_dir}
	echo

	http_code=$(curl --silent --head --write-out '%{http_code}' "$web_nfs_url/${image_file}" | grep HTTP | awk '{print $2}')
	if [[ "$http_code" -ne 200 ]]; then
		echo "$web_nfs_url/${image_file} is NOT working."
	else
		echo "${image_file} can be downloaded from: $web_nfs_url/${image_file}"
	fi
	echo
fi

rm -f $tmp0
podman stop container1
podman rm container1
images=$(podman images | awk '{print $3}'| tr -d 'IMAGE')
for i in $images; do podman rmi -f $i; done
podman rmi "localhost/${image_file}"
