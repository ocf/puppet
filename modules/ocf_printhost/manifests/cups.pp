class ocf_printhost::cups {
  package { [ 'cups', 'cups-bsd' ]: }
  ocf::repackage { 'hplip':
    recommends => false
  }
  service { 'cups': }

  File {
    require => Package['cups'],
    notify  => Service['cups'],
  }

  file {
    '/etc/cups/cupsd.conf':
      content => template('ocf_printhost/cups/cupsd.conf.erb');
    '/etc/cups/cups-files.conf':
      content => template('ocf_printhost/cups/cups-files.conf.erb');
    '/etc/cups/lpoptions':
      content => 'Default double';
    ['/etc/cups/raw.convs', '/etc/cups/raw.types']:
      content => '# deny printing raw jobs';
    '/etc/cups/ppd':
      ensure  => directory;
    ['/etc/cups/ppd/deforestation-double.ppd', '/etc/cups/ppd/logjam-double.ppd']:
      source  => 'puppet:///modules/ocf_printhost/cups/double.ppd',
      require => File['/etc/cups/ppd'];
    ['/etc/cups/ppd/deforestation-single.ppd', '/etc/cups/ppd/logjam-single.ppd']:
      source  => 'puppet:///modules/ocf_printhost/cups/single.ppd',
      require => File['/etc/cups/ppd'];
    '/etc/cups/printers.conf':
      owner   => 'lp',
      mode    => '0600',
      source  => 'puppet:///modules/ocf_printhost/cups/printers.conf';
    '/etc/cups/classes.conf':
      owner   => 'lp',
      mode    => '0600',
      source  => 'puppet:///modules/ocf_printhost/cups/classes.conf';
  }

  mount { '/var/spool/cups':
    device  => 'tmpfs',
    fstype  => 'tmpfs',
    options => 'mode=0710,gid=lp,noatime,nodev,noexec,nosuid';
  }
}
