class lightning::apt-dater {
  package { 'apt-dater': }

  file { '/root/apt-dater.keytab':
    mode   => 600,
    backup => false,
    source => 'puppet:///private/apt-dater.keytab';
  }
}
