class ocf_mesos::master::secrets {
  file { '/opt/share/secrets':
    mode    => '0700',
    source  => 'puppet:///private-docker/',
    recurse => true,
  }
}
