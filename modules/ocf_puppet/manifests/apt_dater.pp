class ocf_puppet::apt_dater {
  package { 'apt-dater': }

  file { '/root/apt-dater.keytab':
    mode   => '0600',
    backup => false,
    source => 'puppet:///private/apt-dater.keytab';
  }
}
