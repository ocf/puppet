class ocf::sysctl {
  file { '/etc/sysctl.d/98-temp-workaround-cve-2016-5696.pp':
    ensure  => file,
    content => "net.ipv4.tcp_challenge_ack_limit = 999999999\n";
  }

  exec { 'sysctl -p /etc/sysctl.d/98-temp-workaround-cve-2016-5696.pp':
    subscribe   => File['/etc/sysctl.d/98-temp-workaround-cve-2016-5696.pp'],
    refreshonly => true;
  }
}
