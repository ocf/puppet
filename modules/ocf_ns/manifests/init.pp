class ocf_ns {
  package { 'bind9':; }
  service { 'bind9':
    require => Package['bind9'];
  }

  $decal_ddns_key = assert_type(Stdlib::Base64, lookup('decal::ddns::key'))
  $letsencrypt_ddns_key = assert_type(Stdlib::Base64, lookup('letsencrypt::ddns::key'))

  file {
    '/etc/bind/named.conf.options':
      content => template('ocf_ns/named.conf.options.erb'),
      mode    => '0640',
      group   => bind,
      require => Package['bind9'],
      notify  => Service['bind9'];

    '/etc/bind/named.conf.local':
      ensure  => link,
      target  => '/srv/dns/etc/named.conf.local',
      require => [Package['bind9'], Vcsrepo['/srv/dns']],
      notify  => Service['bind9'];
  }

  # Flush BIND journals to zone files and remove .jnl files before git pull.
  # Without this, git overwrites zone files that have pending journal entries
  # (from dynamic updates or inline signing), causing "journal out of sync
  # with zone" errors on reload.
  exec { 'bind9-sync-clean':
    command => '/usr/sbin/rndc sync -clean',
    require => Service['bind9'],
    before  => Vcsrepo['/srv/dns'],
  }

  vcsrepo { '/srv/dns':
    ensure   => latest,
    provider => git,
    owner    => 'bind',
    group    => 'bind',
    revision => 'master',
    source   => 'https://github.com/ocf/dns.git',
    require  => Package['bind9'],
    notify   => Exec['bind9-reload'],
  }

  exec { 'bind9-reload':
    command     => '/usr/sbin/rndc reload',
    refreshonly => true,
    require     => Service['bind9'],
  }

  ocf::firewall::firewall46 {
    '101 allow domain':
      opts => {
        chain  => 'PUPPET-INPUT',
        proto  => ['tcp', 'udp'],
        dport  => 53,
        action => 'accept',
      };
  }
}
