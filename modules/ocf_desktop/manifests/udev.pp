class ocf_desktop::udev {
  package { ['u2f-host']:; }

  file { '/etc/udev/rules.d/70-u2f-fido.rules':
    source    => 'puppet:///modules/ocf_desktop/70-u2f-fido.rules',
    mode      => '0644',
  }
}
