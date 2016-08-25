class ocf_printhost::cups {
  package { ['cups', 'cups-bsd']: }

  service { 'cups':
    require => Package['cups', 'cups-bsd'],
  }

  $file_defaults = {
    require => Package['cups', 'cups-bsd'],
    notify  => Service['cups'],
  }

  file {
    default:
      * => $file_defaults;

    '/etc/cups/cupsd.conf':
      content => template('ocf_printhost/cups/cupsd.conf.erb');

    '/etc/cups/cups-files.conf':
      content => template('ocf_printhost/cups/cups-files.conf.erb');

    '/etc/cups/lpoptions':
      content => "Default double\n";

    ['/etc/cups/raw.convs', '/etc/cups/raw.types']:
      content => "# deny printing raw jobs\n";

    '/etc/cups/ppd':
      ensure  => directory,
      source  => 'puppet:///modules/ocf_printhost/cups/ppd',
      group   => 'lp',
      recurse => true;

    '/etc/cups/printers.conf':
      replace => false,
      group   => lp,
      mode    => '0600',
      source  => 'puppet:///modules/ocf_printhost/cups/printers.conf';

    '/etc/cups/classes.conf':
      replace => false,
      group   => 'lp',
      mode    => '0600',
      source  => 'puppet:///modules/ocf_printhost/cups/classes.conf';
  }

  mount { '/var/spool/cups':
    device  => 'tmpfs',
    fstype  => 'tmpfs',
    options => 'mode=0710,gid=lp,noatime,nodev,noexec,nosuid';
  }
}
