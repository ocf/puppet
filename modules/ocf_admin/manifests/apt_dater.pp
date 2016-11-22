class ocf_admin::apt_dater {
  ocf::repackage { 'apt-dater':
    backport_on => jessie,
  }

  file { '/root/apt-dater.keytab':
    mode   => '0600',
    backup => false,
    source => 'puppet:///private/apt-dater.keytab';
  }
}
