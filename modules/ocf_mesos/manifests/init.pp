class ocf_mesos {
  include ocf::firewall::allow_web

  file { '/opt/share/mesos':
    ensure => directory;
  }
}
