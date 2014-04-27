class desktop::grub {
  # password protection to prevent modifying kernel options
  file { "/etc/grub.d/01_ocf":
    owner  => root,
    group  => root,
    mode   => 500,
    source => "puppet:///contrib/desktop/grub/01_ocf";
  }

  exec { "update-grub":
    subscribe   => File["/etc/grub.d/01_ocf"],
    refreshonly => true;
  }
}
