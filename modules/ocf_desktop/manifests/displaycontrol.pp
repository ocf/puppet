class ocf_desktop::displaycontrol {

  kmod::load { 'i2c_dev': }

  package { [ 'i2c-tools', 'ddcutil' ]: }
}
