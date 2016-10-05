class ocf::sysctl {
  file { '/etc/sysctl.d/98-temp-workaround-cve-2016-5696.conf':
    ensure  => absent,
  }
}
