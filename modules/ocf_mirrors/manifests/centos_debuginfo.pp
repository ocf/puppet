class ocf_mirrors::centos_debuginfo {
  file { '/opt/mirrors/project/centos-debuginfo':
    ensure  => directory,
    source  => 'puppet:///modules/ocf_mirrors/project/centos-debuginfo/',
    owner   => mirrors,
    group   => mirrors,
    mode    => '0755',
    recurse => true,
  }

  ocf_mirrors::monitoring {
    'centos-debuginfo':
      ensure        => absent,
      type          => 'unix_timestamp',
      upstream_path => '/',
      upstream_host => 'debuginfo.centos.org',
      ts_path       => 'TIME';
  }

  ocf::systemd::timer { 'centos-debuginfo':
    ensure => absent;
  }
}
