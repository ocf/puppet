class ocf_printhost::cups($dev_config = false) {
  package { ['cups', 'cups-bsd']: }

  service { 'cups':
    require => Package['cups', 'cups-bsd'],
  }

  file {
    default:
      require => Package['cups', 'cups-bsd'],
      notify  => Service['cups'];

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
      group   => 'lp';

    ['/etc/cups/ppd/papercut-single.ppd', '/etc/cups/ppd/pagefault-single.ppd']:
      content => epp('ocf_printhost/cups/ppd/m806.ppd.epp', { 'double' => false });

    ['/etc/cups/ppd/papercut-double.ppd', '/etc/cups/ppd/pagefault-double.ppd']:
      content => epp('ocf_printhost/cups/ppd/m806.ppd.epp', { 'double' => true });

    '/etc/cups/printers.conf':
      replace => false,
      group   => 'lp',
      mode    => '0600',
      source  => 'puppet:///modules/ocf_printhost/cups/printers.conf';

    '/etc/cups/classes.conf':
      replace => false,
      group   => 'lp',
      mode    => '0600',
      source  => 'puppet:///modules/ocf_printhost/cups/classes.conf';

    '/usr/lib/cups/filter/ocfps/':
      source  => 'puppet:///modules/ocf_printhost/ocfps',
      mode    => '0755';
  }

  mount { '/var/spool/cups':
    device  => 'tmpfs',
    fstype  => 'tmpfs',
    options => 'mode=0710,gid=lp,noatime,nodev,noexec,nosuid';
  }
}
