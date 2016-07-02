class ocf_mesos {
  file { '/opt/share/mesos':
    ensure => directory;
  }
}
