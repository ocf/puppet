class ocf_desktop::displaycontrol {

  file {
    '/etc/modules-load.d/i2c.conf':
      mode    => '0644',
      content => 'i2c_dev\n',
  }

  exec { 'load-modules':
    command     => '/lib/systemd/systemd-modules-load',
    subscribe   => File['/etc/modules-load.d/i2c.conf'],
    refreshonly => true,
  }

  package { [ 'i2c-tools', 'ddcutil' ]: }
}
