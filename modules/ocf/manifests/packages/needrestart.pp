class ocf::packages::needrestart {
  # TODO: clean this up
  # We use needrestart to determine if a reboot is needed due to a kernel
  # upgrade on desktops.
  package { 'needrestart':
    ensure => purged;
  }

  # We disable the apt hook; there are two modes:
  #  - interactive, where it's super annoying to a staffer running apt-dater
  #  - automatic, where it will automatically restart things without caring
  #    (including things like lightdm, even if a user is logged in!)
  # file { '/etc/apt/apt.conf.d/99needrestart':
  #   content => "# Disabled by OCF\n",
  #   require => Package['needrestart'];
  # }
}
