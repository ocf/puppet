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

    # place files to handle daisy chain sleep issue
    '/usr/lib/pm-utils/sleep.d/999fix-daisy':
      mode   => '0755',
      source => 'puppet:///modules/ocf_desktop/suspend/fix-daisy';

    # place files to handle daisy chain sleep issue
    '/usr/lib/pm-utils/power.d/fix-daisy':
      mode   => '0755',
      source => 'puppet:///modules/ocf_desktop/suspend/fix-daisy';
  }


  package {
    # ACPI support
    'acpi-support-base':;
    # power management
    'pm-utils':;
  }

  cron { 'ocf-suspend':
    command => '/usr/local/sbin/ocf-suspend -q',
    minute  => '*/15',
    require => File['/usr/local/sbin/ocf-suspend'],
  }

  # restart acpi
  service { 'acpid':
    subscribe => File['/etc/acpi/events/powerbtn-acpi-support'],
  }
}
