class ocf_desktop::drivers {
    augeas { 'grub_nomodeset':
      context => '/files/etc/default/grub',
      changes => [
        # Add nomodeset to grub command-line options (quiet is the default)
        'set GRUB_CMDLINE_LINUX_DEFAULT \'"quiet nomodeset"\'',
      ],
      notify  => Exec['update-grub'],
    }
  }

}
