#!/bin/bash

PUPPET="/opt/puppetlabs/bin/puppet"
PUPPETFORGE_MODULES_PATH="/opt/puppetforge/modules"
GIT_HOST="bitbucket.org"
GIT_USERNAME="jamesbmichael"
#TODO: This has to be fetched from Environment or from AWS Secrets Manager
GIT_ACCESSKEY='92W32wpgManx9KaeFtNy'

function puppet_module_install() {
    #TODO: This install fails if not run with sudo. Or the modules path should be owned by the user who is running this command.
    ${PUPPET} module install -f --target-dir ${PUPPETFORGE_MODULES_PATH} $1 --version $2
}

function centizen_module_install() {
    # Check if module directory exists. If yes, just pull
    if [ -d "${PUPPETFORGE_MODULES_PATH}/$2" ]; then
        echo "Module $2 already present."
    else
        git clone https://${GIT_USERNAME}:${GIT_ACCESSKEY}@${GIT_HOST}/devops/$1.git ${PUPPETFORGE_MODULES_PATH}/$2
        git clone https://${GIT_USERNAME}:${GIT_ACCESSKEY}@${GIT_HOST}/commandcredit/$1.git ${PUPPETFORGE_MODULES_PATH}/$2
    fi
}

echo "Installing puppet forge opensource modules"
puppet_module_install puppetlabs-stdlib 5.1.0
puppet_module_install puppetlabs-docker 3.1.0
puppet_module_install puppetlabs-apt 6.2.1
puppet_module_install puppet-nodejs 6.0.0
puppet_module_install puppet-wget 2.0.1
puppet_module_install puppetlabs-apache 4.0.0
puppet_module_install puppetlabs-concat 5.3.0
puppet_module_install puppetlabs-mysql 8.1.0
puppet_module_install puppet-letsencrypt 4.0.0
puppet_module_install puppetlabs-inifile 3.0.0

echo "Installing puppet forge centizen modules"
centizen_module_install puppet-utilities utilities
centizen_module_install puppet-accredit accredit
