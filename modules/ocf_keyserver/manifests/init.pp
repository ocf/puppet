class ocf_keyserver {
  require ocf::ssl::default
  include ocf::firewall::allow_web
  include ocf::packages::docker

  file {
    '/var/lib/sks':
      ensure  => directory;

    '/var/lib/sks/sksconf':
      content => template('ocf_keyserver/sksconf.erb');

    '/var/lib/sks/membership':
      source  => 'puppet:///modules/ocf_keyserver/membership';
  }

  ocf::systemd::service { 'sks-keyserver':
    source  => 'puppet:///modules/ocf_keyserver/sks-keyserver.service',
    require => [
      Package['docker-ce'],
      File['/var/lib/sks'],
    ];
  }

  class { 'nginx':
    manage_repo  => false,
    confd_purge  => true,
    server_purge => true;
  }

  Class['ocf::ssl::default'] ~> Class['Nginx::Service']

  # not using the nginx resource because I can't figure out
  # how to recreate this config in 'native' puppet-nginx
  file {
    '/etc/nginx/sites-enabled/sks-web-proxy.conf':
      content => template('ocf_keyserver/sks-web-nginx.erb'),
      notify  => Class['Nginx::Service'];
  }

  ocf::firewall::firewall46 {
    '101 allow sks-recon':
      opts => {
        chain  => 'PUPPET-INPUT',
        proto  => ['tcp'],
        dport  => 11370,
        action => 'accept',
      };
  }

  ocf::firewall::firewall46 {
    '101 allow sks-hkp':
      opts => {
        chain  => 'PUPPET-INPUT',
        proto  => ['tcp'],
        dport  => 11371,
        action => 'accept',
      };
  }
}
