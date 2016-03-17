class ocf_printhost::cups {
  package { [ 'cups', 'cups-bsd' ]: }
  ocf::repackage { 'hplip':
    recommends => false
  }
  service { 'cups':
    require => Package['cups', 'cups-bsd']
  }

  File {
    require => Package['cups', 'cups-bsd'],
    notify  => Service['cups'],
  }

  file {
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
    ['/etc/cups/ppd/deforestation-double.ppd', '/etc/cups/ppd/logjam-double.ppd']:
      source  => 'puppet:///modules/ocf_printhost/cups/double.ppd';
    ['/etc/cups/ppd/deforestation-single.ppd', '/etc/cups/ppd/logjam-single.ppd']:
      source  => 'puppet:///modules/ocf_printhost/cups/single.ppd';
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
