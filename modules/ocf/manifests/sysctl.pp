class ocf::sysctl {
  file { '/etc/sysctl.d/98-temp-workaround-cve-2016-5696.conf':
    ensure  => file,
    content => "net.ipv4.tcp_challenge_ack_limit = 999999999\n";
  }

  file { '/etc/sysctl.d/98-temp-workaround-cve-2016-5696.pp':
    ensure => absent;
  }

  exec { 'sysctl -p /etc/sysctl.d/98-temp-workaround-cve-2016-5696.conf':
    subscribe   => File['/etc/sysctl.d/98-temp-workaround-cve-2016-5696.conf'],
    refreshonly => true;
  }
}
