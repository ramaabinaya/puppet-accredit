# A description of what this class does
#
# @summary A short summary of the purpose of this class
#
# @example
#   include accredit::setup::install
class accredit::setup::install {

  file { ['/opt/accredit', '/opt/accredit/node',"/opt/accredit/node/$accredit::version","/opt/accredit/node/$accredit::version1"] :
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
    command => "/usr/local/bin/aws s3 cp s3://accredit-jenkins/builds/accredit/$accredit::version/express.tar $accredit::version-express.tar",
    cwd     => '/opt/accredit',
    path    => '/usr/local/bin/:/bin/:/sbin/:/usr/bin/:/usr/sbin/',
    notify  => Exec['extract_currentbuild'],
    unless  => "test -f /opt/accredit/$accredit::version-express.tar",
  }

  exec { 'extract_currentbuild' :
    command     => "tar -xvf /opt/accredit/$accredit::version-express.tar -C /opt/accredit/node/$accredit::version",
    path        => '/bin/:/sbin/:/usr/bin/:/usr/sbin/',
    require     => Exec['download_accredit_package'],
    refreshonly => true,
  }
 exec { 'download_accreditdist_package' :
    command => "/usr/local/bin/aws s3 cp s3://accredit-jenkins/builds/accredit/$accredit::version/dist.tar $accredit::version-dist.tar",
    cwd     => '/var/www',
    path    => '/usr/local/bin/:/bin/:/sbin/:/usr/bin/:/usr/sbin/',
    notify  => Exec['extract_build'],
    unless  => "test -f /var/www/$accredit::version-dist.tar",
  }

  exec { 'extract_build' :
    command     => "tar -xvf /var/www/$accredit::version-dist.tar --strip-components 1 -C /var/www/html/$accredit::version",
    path        => '/bin/:/sbin/:/usr/bin/:/usr/sbin/',
    require     => Exec['download_accreditdist_package'],
    notify      => Exec['pm2_start'],
    refreshonly => true,
  }

  exec { "chown -R www-data:www-data /var/www/html/$accredit::version" :
      path    => '/bin/:/sbin/:/usr/bin/:/usr/sbin/',
      require => Exec['extract_build'],
    }
 exec { 'download_accreditexpress_package' :
    command => "/usr/local/bin/aws s3 cp s3://accredit-jenkins/builds/accredit-api/$accredit::version1/express.tar $accredit::version1-express.tar",
    cwd     => '/opt/accredit',
    path    => '/usr/local/bin/:/bin/:/sbin/:/usr/bin/:/usr/sbin/',
    notify  => Exec['extract_currentapibuild'],
    unless  => "test -f /opt/accredit/$accredit::version1-dist.tar",
  }
exec { 'extract_currentapibuild' :
    command     => "tar -xvf /opt/accredit/$accredit::version1-express.tar -C /opt/accredit/node/$accredit::version1",
    path        => '/bin/:/sbin/:/usr/bin/:/usr/sbin/',
    require     => Exec['download_accreditexpress_package'],
    notify      => Exec['pm2_start1'],
    refreshonly => true,
  }

  exec { 'pm2_start':
    environment => ["HOME=/home/ubuntu"],
    path        => '/usr/local/bin/:/bin/:/sbin/:/usr/bin/:/usr/sbin/',
    cwd         => "/opt/accredit/node/$accredit::version/express",
    user        => 'ubuntu',
    command     => 'pm2 start ./bin/www',
    refreshonly => true,
  }
exec { 'pm2_start1':
    environment => ["HOME=/home/ubuntu"],
    path        => '/usr/local/bin/:/bin/:/sbin/:/usr/bin/:/usr/sbin/',
    cwd         => "/opt/accredit/node/$accredit::version1/express",
    user        => 'ubuntu',
    command     => 'pm2 start ./bin/www',
    refreshonly => true,
  }

}
