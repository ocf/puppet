class networking::resolvconf($domain, $nameservers,) {

  package { 'resolvconf':
    ensure => purged,
  }

  if $domain != undef and $nameservers != undef {
    file { '/etc/resolv.conf':
      content => template('networking/resolv.conf.erb'),
      require => Package['resolvconf'],
    }
  }

}
