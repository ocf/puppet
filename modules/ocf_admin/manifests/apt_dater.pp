class ocf_admin::apt_dater {
  package { 'apt-dater':; }

  ocf::privatefile { '/root/apt-dater.keytab':
    mode   => '0600',
    source => 'puppet:///private/apt-dater.keytab';
  }
}
