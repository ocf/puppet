class ocf_filehost {
  package { 'nfs-kernel-server':; }
  service { 'nfs-kernel-server':; }

  file { '/etc/exports':
    source => 'puppet:///modules/ocf_filehost/exports',
    notify => Service['nfs-kernel-server'];
  }
}
