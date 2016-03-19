class ocf_desktop::suspend {
  file {
    # suspend script with scheduled wakeup, also attempt resetting tmpfs
    '/usr/local/sbin/ocf-suspend':
      mode    => '0755',
      source  => 'puppet:///modules/ocf_desktop/suspend/ocf-suspend',
      require => Package['ethtool', 'pm-utils', 'python3-ocflib'];

    # run script when power button is pushed
    '/etc/acpi/events/powerbtn-acpi-support':
      source  => 'puppet:///modules/ocf_desktop/suspend/powerbtn-acpi-support',
      require => Package['acpi-support-base'];

    # TODO: remove this in a few weeks
    '/etc/cron.d/ocf-suspend':
      ensure  => absent;
  }

  package {
    # ACPI support
    'acpi-support-base':;
    # install anacron since machine is not continuously running
    'anacron':;
    # install ethtool to allow script to enable WOL
    'ethtool':;
    # power management
    'pm-utils':;
  }

  cron { 'ocf-suspend':
    command => '/usr/local/sbin/ocf-suspend -q',
    minute  => '*',
    hour    => '*',
    require => [Package['anacron'], File['/usr/local/sbin/ocf-suspend']],
  }

  # restart acpi
  service { 'acpid':
    subscribe => File['/etc/acpi/events/powerbtn-acpi-support'],
  }
}
