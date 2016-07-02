class ocf_mesos::slave::secrets {
  file { '/opt/share/secrets':
    mode    => '0600',
    source  => 'puppet:///private-docker/',
    recurse => true,
    purge   => true,
    force   => true,
  }
}
