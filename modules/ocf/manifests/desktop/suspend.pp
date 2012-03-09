class ocf::desktop::suspend {

  require ocf::desktop::packages
  require ocf::desktop::tmpfs

  file {
    # suspend script with scheduled wakeup, also attempt resetting tmpfs
    '/usr/local/sbin/ocf-suspend':
      mode    => '0755',
      source  => 'puppet:///modules/ocf/desktop/suspend/ocf-suspend',
      require => Package[ 'ethtool', 'pm-utils' ];
    # run script when power button is pushed
    '/etc/acpi/events/powerbtn-acpi-support':
      source  => 'puppet:///modules/ocf/desktop/suspend/powerbtn-acpi-support';
    # run script off hours
    '/etc/cron.d/ocf-suspend':
      source  => 'puppet:///modules/ocf/desktop/suspend/crontab',
      require => [ Package['anacron'], File['/usr/local/sbin/ocf-suspend'] ]
  }

  package {
    # install anacron since machine is not continuously running
    'anacron':;
    # install ethtool to allow script to enable WOL
    'ethtool':
  }

  # restart acpi
  service { 'acpid':
    subscribe => File['/etc/acpi/events/powerbtn-acpi-support']
  }

}
