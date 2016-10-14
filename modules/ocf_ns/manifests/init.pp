class ocf_ns {
  package { 'bind9':; }
  service { 'bind9':
    require => Package['bind9'];
  }

  file {
    '/etc/bind/named.conf.options':
      source  => 'puppet:///modules/ocf_ns/named.conf.options',
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
    revision => 'master',
    source   => 'https://github.com/ocf/dns.git',
    require  => Package['bind9'],
    notify   => Service['bind9'];
  }

  ocf::munin::plugin { 'ping-report':
    source => 'puppet:///modules/ocf_ns/ping-report',
  }
}
