class ocf::local::printhost {

  # set up cups
  package { [ 'cups', 'cups-bsd' ]: }
  ocf::repackage { 'hplip':
    recommends => false
  }
  file {
    # provide config
    '/etc/cups/cupsd.conf':
      path    => '/etc/cups/cupsd.conf',
      source  => 'puppet:///modules/ocf/local/printhost/cupsd.conf',
      require => Package[ 'cups', 'cups-bsd' ];
    # set default printer double
    '/etc/cups/lpoptions':
      content => 'Default double',
      require => Package[ 'cups', 'cups-bsd' ];
    # deny printing raw jobs
    [ '/etc/cups/raw.convs', '/etc/cups/raw.types' ]:
      content => '# deny printing raw jobs',
      require => Package[ 'cups', 'cups-bsd' ];
    # provide ssl certificates
    '/etc/cups/ssl':
      ensure  => directory,
      mode    => '0600',
      group   => lp,
      recurse => true,
      purge   => true,
      force   => true,
      backup  => false,
      source  => 'puppet:///private/cups-ssl',
      require => Package[ 'cups', 'cups-bsd' ]
  }
  # mount /var/spool/cups in tmpfs
  mount { '/var/spool/cups':
    device  => 'tmpfs',
    fstype  => 'tmpfs',
    options => 'mode=0710,gid=lp,noatime,nodev,noexec,nosuid';
  }
  # restart cups
  service { 'cups':
    subscribe => File[ '/etc/cups/cupsd.conf', '/etc/cups/lpoptions', '/etc/cups/raw.convs', '/etc/cups/raw.types', '/etc/cups/ssl' ]
  }

  # set up pykota
  package {
    'mysql-server':;
    # pykota python dependencies
    [ 'pkpgcounter', 'python-egenix-mxdatetime', 'python-imaging', 'python-jaxml', 'python-minimal', 'python-mysqldb', 'python-osd', 'python-pysnmp4', 'python-reportlab' ]:
  }
  file {
    # configuration directory
    '/etc/pykota':
      ensure  => directory,
      recurse => true,
      purge   => true,
      force   => true;
    # public configuration
    '/etc/pykota/pykota.conf':
      source  => 'puppet:///modules/ocf/local/printhost/pykota.conf';
    # private configuration
    '/etc/pykota/pykotadmin.conf':
      owner   => lp,
      group   => printing,
      mode    => '0640',
      source  => 'puppet:///private/pykotadmin.conf'
  }
  # export pykota configuration
  package { 'nfs-kernel-server': }
  file { '/etc/exports':
    source    => 'puppet:///modules/ocf/local/printhost/exports',
    require   => Package['nfs-kernel-server']
  }
  service { 'nfs-kernel-server':
    subscribe => File['/etc/exports'],
    require   => Package['nfs-kernel-server']
  }

  # reboot at midnight
  #cron { 'reboot':
  #  command => '/sbin/reboot',
  #  hour    => 00,
  #  minute  => 01
  #}

}
