# accredit
#
# A description of what this class does
#
# @summary A short summary of the purpose of this class
#
# @example
#   include accredit
class accredit($accreditapp,$accreditapi) {

  class { 'utilities::autouser' :
    username => 'zenuser'
  }
  class { 'docker' :
    docker_users => ['ubuntu', 'zenuser'],
  }
  include utilities::awscli

  include accredit::setup::database
  include accredit::setup::apache
  class { 'accredit::setup::install' :
    require => Class[ 'docker',
                      'utilities::awscli',
                      'accredit::setup::apache',
                      'accredit::setup::database'
                      ]
  }

}
