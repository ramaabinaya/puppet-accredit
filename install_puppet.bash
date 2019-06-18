#!/bin/bash                                                                     

PUPPET_AGENT_VERSION="6.1.0"
UBUNTU_CODENAME="bionic"

apt-get update
apt-get install --no-install-recommends -y wget ca-certificates lsb-release
wget https://apt.puppetlabs.com/puppet6-release-"$UBUNTU_CODENAME".deb
dpkg -i puppet6-release-"$UBUNTU_CODENAME".deb
rm puppet6-release-"$UBUNTU_CODENAME".deb
apt-get update
apt-get install --no-install-recommends -y puppet-agent="$PUPPET_AGENT_VERSION"\
-1"$UBUNTU_CODENAME"
apt-get install -y git
mkdir -p /opt/puppetforge/modules
chmod 777 /opt/puppetforge/modules

/opt/puppetlabs/bin/puppet --version
