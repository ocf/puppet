class ocf_accounts::nfs {
  # TODO: can we store /opt/create on pandemic instead so that earthquake can
  # be stateless?
  package { 'nfs-kernel-server':; }
  service { 'nfs-kernel-server':
    require => Package['nfs-kernel-server'];
  }

  file {
    '/etc/exports':
      source  => 'puppet:///modules/ocf_accounts/exports',
      require => File['/opt/create/public'],
      notify  => Service['nfs-kernel-server'];

    ['/opt/create', '/opt/create/public']:
      ensure  => directory;
  }
}
