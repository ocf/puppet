class ocf_mesos {
  include ocf::firewall::allow_http

  file { '/opt/share/mesos':
    ensure => directory;
  }
}
