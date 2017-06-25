class ocf::ipmi {
  # Install ipmi tools
  package { 'ipmitool':; }

  # Enable IPMI kernel modules
  file { '/etc/modules-load.d/ipmi.conf':
    content => "ipmi_devintf\nipmi_si\n";
  }
}
