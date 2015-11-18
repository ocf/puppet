class ocf_www::ocfweb {
  include ocf_ssl
  package { 'ocfweb':
    ensure  => latest,
    require => Exec['ocfweb: apt-get update'];
  }
  exec { 'ocfweb: apt-get update':
    command => 'apt-get update';
  }
  service { 'ocfweb':
    require => Package['ocfweb'];
  }
  exec { 'ocfweb-gen-secret':
    command => 'sed -i "s/^secret = not_a_secret$/secret = $(pwgen -s -n1 64)/" /etc/ocfweb/ocfweb.conf',
    onlyif  => 'grep -E "^secret = not_a_secret$" /etc/ocfweb/ocfweb.conf',
    require => Package['ocfweb'],
    notify  => Service['ocfweb'];
  }

  class { 'nginx':
    # if we let nginx manage its own repo, it uses the `apt` module; this
    # creates an unresolvable dependency cycle because we declare class `apt`
    # in stage first (and we're currently in stage main)
    manage_repo => false;
  }

  nginx::resource::upstream { 'ocfweb':
    members => ['localhost:8000'];
  }

  nginx::resource::vhost {
    # proxy to ocfweb running on localhost:8000;
    # this is intended to be accessed only by death, not by the public
    'ocfweb.ocf.berkeley.edu':
      server_name => ['ocfweb.ocf.berkeley.edu', 'ocfweb'],

      proxy            => 'http://ocfweb',
      proxy_set_header => [
        'X-Forwarded-Proto https',
        'X-Forwarded-For $proxy_add_x_forwarded_for',
        'Host $host'
      ],

      listen_port      => 8001;

    # serve static assets to the public (not death)
    'static.ocf.berkeley.edu':
      www_root => '/usr/share/ocfweb/static',

      server_name => ['static.ocf.berkeley.edu'],

      ssl         => true,
      ssl_cert    => "/etc/ssl/private/${::fqdn}.bundle",
      ssl_key     => "/etc/ssl/private/${::fqdn}.key",
      ssl_dhparam => '/etc/ssl/dhparam.pem',

      add_header  => {
        'Strict-Transport-Security'   => 'max-age=31536000',
        'Access-Control-Allow-Origin' => '*',
      },

      listen_port      => 443,
      rewrite_to_https => true;
  }
}
