class ocf_admin::apt_dater {
  package { 'apt-dater':; }

  if $::use_private_share {
    file { '/root/apt-dater.keytab':
      mode   => '0600',
      backup => false,
      source => 'puppet:///private/apt-dater.keytab';
    }
  }
}
