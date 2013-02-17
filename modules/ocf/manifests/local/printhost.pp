class ocf::local::printhost {

  # set up cups
  package { [ 'cups', 'cups-bsd' ]: }
  ocf::repackage { 'hplip':
    recommends => false
  }
  file {
    # provide cups config
    '/etc/cups/cupsd.conf':
      source  => 'puppet:///modules/ocf/local/printhost/cupsd.conf',
      require => Package['cups'],
      notify  => Service['cups'],
    ;
    # provide more sensitive cups config
    '/etc/cups/cups-files.conf':
      source  => 'puppet:///modules/ocf/local/printhost/cups-files.conf',
      require => Package['cups'],
      notify  => Service['cups'],
    ;
    # set default printer double
    '/etc/cups/lpoptions':
      content => 'Default double',
      require => Package[ 'cups'],
      notify  => Service['cups'],
    ;
    # deny printing raw jobs
    [ '/etc/cups/raw.convs', '/etc/cups/raw.types' ]:
      content => '# deny printing raw jobs',
      require => Package['cups'],
      notify  => Service['cups'],
    ;
    # provide ssl certificate and key
    '/etc/cups/ssl':
      ensure  => directory,
      mode    => '0600',
      group   => lp,
      backup  => false,
      source  => 'puppet:///private/cups-ssl',
      require => Package['cups'],
      notify  => Service['cups'],
    ;
  }
  # mount /var/spool/cups in tmpfs
  mount { '/var/spool/cups':
    device  => 'tmpfs',
    fstype  => 'tmpfs',
    options => 'mode=0710,gid=lp,noatime,nodev,noexec,nosuid';
  }
  service { 'cups': }

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
    ;
    '/etc/pykota/pykota.semester':
      ensure  => directory,
    ;
    # public configuration
    '/etc/pykota/pykota.semester/pykota.conf':
      source  => 'puppet:///modules/ocf/local/printhost/pykota-semester.conf',
    ;
    '/etc/pykota/pykota.conf':
      source  => 'puppet:///modules/ocf/local/printhost/pykota.conf',
    ;
    '/etc/pykota/pykotadmin.conf':
      owner   => 'lp',
      group   => 'ocfstaff',
      mode    => '0640',
      source  => 'puppet:///modules/ocf/local/printhost/pykotadmin.conf',
    ;
    '/etc/pykota/update_semester_quota.sh':
      mode    => '0755',
      source  => 'puppet:///modules/ocf/local/printhost/update_semester_quota.sh',
    ;
    '/etc/pykota/set_daily_quota.sh':
      mode    => '0755',
      source  => 'puppet:///modules/ocf/local/printhost/set_daily_quota.sh',
    ;
    '/etc/pykota/reset_daily_quota.sh':
      mode    => '0755',
      source  => 'puppet:///modules/ocf/local/printhost/reset_daily_quota.sh',
    ;
    # private configuration
    '/etc/pykota/pykota.semester/pykotadmin.conf':
      owner   => 'lp',
      group   => 'ocfstaff',
      mode    => '0640',
      source  => 'puppet:///private/pykotadmin-semester.conf'
    ;
  }

  # share pykota configuration over NFS
  package { 'nfs-kernel-server': }
  file { '/etc/exports':
    source    => 'puppet:///modules/ocf/local/printhost/exports',
    require   => Package['nfs-kernel-server']
  }
  service { 'nfs-kernel-server':
    subscribe => File['/etc/exports'],
    require   => Package['nfs-kernel-server']
  }

}
