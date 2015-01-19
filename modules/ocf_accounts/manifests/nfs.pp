class ocf_accounts::nfs {
  package { 'nfs-kernel-server':; }
  service { 'nfs-kernel-server':
    require => Package['nfs-kernel-server'];
  }

  file { '/etc/exports':
    source => 'puppet:///modules/ocf_accounts/exports',
    notify => Service['nfs-kernel-server'];
  }
}
