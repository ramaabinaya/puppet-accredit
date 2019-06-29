# A description of what this class does
#
# @summary A short summary of the purpose of this class
#
# @example
#   include accredit::setup::apache
class accredit::setup::apache {
class { 'apache':
  default_vhost     => false,
  default_ssl_vhost => false,
}

  include apache::mod::proxy
  include apache::mod::proxy_http
  include apache::mod::ssl
  include apache::mod::rewrite
  apache::vhost { 'dev.accredit.centizenapps.com':
    port          => '80',
    docroot       => "/var/www/html/$accredit::version",
    docroot_owner => 'www-data',
    docroot_group => 'www-data',
    rewrites      => [{ rewrite_rule => ['^/api/(.*)  http://localhost:3000/$1 [L,P]'] },
                      { rewrite_rule => ['^/restapi/(.*)  http://localhost:4000/$1 [L,P]'] },
                      { rewrite_cond =>['%{DOCUMENT_ROOT}%{REQUEST_URI} -f [OR]',
                                        '%{DOCUMENT_ROOT}%{REQUEST_URI} -d',
                                      ],
                        rewrite_rule =>['^ - [L]'],
                      },
                      {  rewrite_rule =>['^ /index.html'],
                      }
                    ]
  }

}
