class ocf_desktop::udev {
  package { ['u2f-host']:; }

  file { '/etc/udev/rules.d/70-u2f-fido.rules':
    source => 'puppet:///modules/ocf_desktop/70-u2f-fido.rules',
    mode   => '0644',
  }

  # For Gamecube controller adapter
  file { '/etc/udev/rules.d/51-gcadapter.rules':
    content => 'SUBSYSTEM=="usb", ENV{DEVTYPE}=="usb_device", ATTRS{idVendor}=="057e", ATTRS{idProduct}=="0337", MODE="0666"'
  }
}
