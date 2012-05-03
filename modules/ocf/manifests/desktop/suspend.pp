class ocf::desktop::suspend {

  require ocf::desktop::tmpfs

  file {
    # suspend script with scheduled wakeup, also attempt resetting tmpfs
    '/usr/local/sbin/ocf-suspend':
      mode    => '0755',
      source  => 'puppet:///modules/ocf/desktop/suspend/ocf-suspend',
      require => Package[ 'ethtool', 'pm-utils' ];
    # run script when power button is pushed
    '/etc/acpi/events/powerbtn-acpi-support':
      source  => 'puppet:///modules/ocf/desktop/suspend/powerbtn-acpi-support',
      require => Package['acpi-support-base'];
    # run script off hours
    '/etc/cron.d/ocf-suspend':
      source  => 'puppet:///modules/ocf/desktop/suspend/crontab',
      require => [ Package['anacron'], File['/usr/local/sbin/ocf-suspend'] ]
  }

  package {
    # ACPI support
    'acpi-support-base':;
    # install anacron since machine is not continuously running
    'anacron':;
    # install ethtool to allow script to enable WOL
    'ethtool':;
    # power management
    'pm-utils':
  }

  # restart acpi
  service { 'acpid':
    subscribe => File['/etc/acpi/events/powerbtn-acpi-support']
  }

}
