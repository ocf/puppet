class ocf_ns {
  package { 'bind9':; }
  service { 'bind9':
    require => Package['bind9'];
  }

  $letsencrypt_ddns_key = assert_type(Stdlib::Base64, hiera('letsencrypt::ddns::key'))

  file {
    '/etc/bind/named.conf.options':
      content => template('ocf_ns/named.conf.options.erb'),
      require => Package['bind9'],
      notify  => Service['bind9'];

    '/etc/bind/named.conf.local':
      ensure  => link,
      target  => '/srv/dns/etc/named.conf.local',
      require => [Package['bind9'], Vcsrepo['/srv/dns']],
      notify  => Service['bind9'];
  }

  vcsrepo { '/srv/dns':
    ensure   => latest,
    provider => git,
    owner    => 'bind',
    group    => 'bind',
    revision => 'master',
    source   => 'https://github.com/ocf/dns.git',
    require  => Package['bind9'],
    notify   => Service['bind9'];
  }

  ocf::munin::plugin { 'ping-report':
    source => 'puppet:///modules/ocf_ns/ping-report',
  }

  # firewall input rules, allow domain (53 t/u), bootps (67 t/u), tftp (69 u)
  ocf::firewall::firewall46 {
    '101 allow domain':
      opts => {
        chain  => 'PUPPET-INPUT',
        proto  => ['tcp', 'udp'],
        dport  => 53,
        action => 'accept',
      };

    '102 allow bootps':
      opts => {
        chain  => 'PUPPET-INPUT',
        proto  => ['tcp', 'udp'],
        dport  => 67,
        action => 'accept',
      };

    '103 allow tftp':
      opts => {
        chain  => 'PUPPET-INPUT',
        proto  => 'udp',
        dport  => 69,
        action => 'accept',
      };
  }
}
