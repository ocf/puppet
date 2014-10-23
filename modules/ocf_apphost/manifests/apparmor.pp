class ocf_apphost::apparmor {
  package { ['apparmor', 'apparmor-utils', 'libpam-apparmor']:; }

  # add the apparmor LSM to the kernel command line; the Debian wiki provides a
  # perl one-liner, but we do it with augeas instead
  augeas { 'enable_apparmor_lsm':
    context => '/files/etc/default/grub',
    changes => [
      'set GRUB_CMDLINE_LINUX \'"apparmor=1 security=apparmor"\''
    ],
    notify  => Exec['update-grub'];
  }

  exec { 'update-grub':
    refreshonly => true;
  }
}
