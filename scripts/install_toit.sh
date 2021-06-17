
#Install EPEL repo for RHEL 7

wget http://download.bos.redhat.com/pub/epel/7/x86_64/e/epel-release-7-5.noarch.rpm
rpm -ivh epel-release-7-5.noarch.rpm

#Install packages by using toit packages.txt or do it individually
#from directory with packages.txt present

yum -y install $(cat packages.txt)

#Note any packages that failed to install above and install manually.  Most should install if pointing to latest EPEL repo

#Install Python PIP for RHEL7 if it failed in above step (assumes Python already installed). Link to article: http://linuxconfig.org/installation-of-pip-the-python-packaging-tool-on-rhel-7-linux

cd /home
wget https://pypi.python.org/packages/source/s/setuptools/setuptools-7.0.tar.gz --no-check-certificate
tar xzf setuptools-7.0.tar.gz
cd setuptools-7.0
python setup.py install
cd /home
wget https://bootstrap.pypa.io/get-pip.py
python get-pip.py
pip --version

#Install Jinja2 manually
cd /home
wget https://pypi.python.org/packages/source/J/Jinja2/Jinja2-2.7.3.tar.gz
tar xzvf Jinja2-2.7.3.tar.gz 
sudo python setup.py install
cd Jinja2-2.7.3/
sudo python setup.py install

# modify requirements.txt and comment out the line for Jinja
cd /home/git_ovs/vswitchperf/
sed -i 's/jinja==2.7.3/#jinja==2.7.3/g' requirements.txt

pip install -r requirements.txt

