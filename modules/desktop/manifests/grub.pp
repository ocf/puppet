class desktop::grub {
  # password protection to prevent modifying kernel options
  file { '/etc/grub.d/01_ocf':
    owner  => root,
    group  => root,
    mode   => '0500',
    source => 'puppet:///contrib/desktop/grub/01_ocf',
    notify => Exec['update-grub'];
  }

  if $::lsbdistcodename == 'jessie' {
    exec {
      # only require password to modify commandline or access grub console
      'sed -i \'s/^CLASS="/CLASS="--unrestricted /\' /etc/grub.d/10_linux':
        unless => 'grep \'^CLASS="--unrestricted \' /etc/grub.d/10_linux',
        notify => Exec['update-grub'];
    }
  } else {
    exec {
      # c1b21cb mistakingly added --unrestricted to all GRUB boot options, with
      # the intention to not require the GRUB username/password on boot.
      #
      # This is the correct approach on jessie, although it's not necessary on
      # wheezy. Unfortunately, the version of grub2 on wheezy doesn't even
      # recognize the option and fails to boot, even after entering the grub
      # username/password.
      #
      # So, we ensure that `--restricted` is not present in grub configs to
      # clean up the previous mistake.
      'sed -i \'s/^CLASS="--unrestricted /CLASS="/\' /etc/grub.d/10_linux':
        onlyif => 'grep \'^CLASS="--unrestricted \' /etc/grub.d/10_linux',
        notify => Exec['update-grub'];
    }
  }

  exec { 'update-grub':
    refreshonly => true;
  }
}
