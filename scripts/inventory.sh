echo "sslverify=false" >> /etc/yum.conf

# install wget in case it's missing
yum -y install wget

# install beaker-client.repo
wget -O /etc/yum.repos.d/beaker-client.repo http://download.lab.bos.redhat.com/beakerrepos/beaker-client-RedHatEnterpriseLinux.repo

# install beaker related packages
yum -y install rhts-test-env beakerlib rhts-devel rhts-python beakerlib-redhat beaker-client beaker-redhat

# create beaker-tasks.repo file
(
	echo [beaker-tasks]
	echo name=beaker-tasks
	echo baseurl=http://beaker.engineering.redhat.com/rpms
	echo enabled=1
	echo gpgcheck=0
	echo skip_if_unavailable=1
) > /etc/yum.repos.d/beaker-tasks.repo

# install git
git_install()
{
	if [ $# -gt 0 ]; then 
		git_dir=$1
	else
		git_dir="/mnt/git_repo"
	fi
	
	echo "Installing Git if not already installed and cloning repo..."
    yum -y install git || true
    mkdir "$git_dir"
	pushd "$git_dir" && git clone git://pkgs.devel.redhat.com/tests/kernel && popd
}

git_install /mnt/tests

pushd /mnt/tests/kernel/networking/inventory/
./runtest.sh 
cat /tmp/nic_info
popd

