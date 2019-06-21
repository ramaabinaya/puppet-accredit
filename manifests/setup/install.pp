# A description of what this class does
#
# @summary A short summary of the purpose of this class
#
# @example
#   include accredit::setup::install
class accredit::setup::install {

  file { ['/opt/accredit', '/opt/accredit/node',"/opt/accredit/node/$accredit::version"] :
    ensure => 'directory'
  }

  class { 'nodejs':
    repo_url_suffix       => '8.x',
    nodejs_package_ensure => '8.16.0-1nodesource1',
  }

  package { 'pm2':
    ensure   => 'present',
    provider => 'npm',
  }

  package { '@angular/cli':
    ensure   => 'present',
    provider => 'npm',
  }

  package { 'webpack':
      ensure   => 'present',
      provider => 'npm',
    }

  exec { 'download_accredit_package' :
    command => "/usr/local/bin/aws s3 cp s3://centizen-jenkins/builds/accredit/$accredit::version/express.tar $accredit::version-express.tar",
    cwd     => '/opt/accredit',
    path    => '/usr/local/bin/:/bin/:/sbin/:/usr/bin/:/usr/sbin/',
    notify  => Exec['extract_currentbuild'],
    unless  => "test -f /opt/accredit/$accredit::version-express.tar",
  }

  exec { 'extract_currentbuild' :
    command     => "tar -xvf /opt/accredit/$accredit::version-express.tar -C /opt/accredit/node/$accredit::version",
    path        => '/bin/:/sbin/:/usr/bin/:/usr/sbin/',
    require     => Exec['download_notus_package'],
    refreshonly => true,
  }

  exec { 'download_accreditdist_package' :
    command => "/usr/local/bin/aws s3 cp s3://centizen-jenkins/builds/accredit/$accredit::version/dist.tar $accredit::version-dist.tar",
    cwd     => '/var/www',
    path    => '/usr/local/bin/:/bin/:/sbin/:/usr/bin/:/usr/sbin/',
    notify  => Exec['extract_build'],
    unless  => "test -f /var/www/$accredit::version-dist.tar",
  }

  exec { 'extract_build' :
    command     => "tar -xvf /var/www/$accredit::version-dist.tar --strip-components 1 -C /var/www/html/$accredit::version",
    path        => '/bin/:/sbin/:/usr/bin/:/usr/sbin/',
    require     => Exec['download_notusdist_package'],
    refreshonly => true,
  }

  exec { "chown -R www-data:www-data /var/www/html/$accredit::version" :
      path    => '/bin/:/sbin/:/usr/bin/:/usr/sbin/',
      require => Exec['extract_build'],
    }

}
