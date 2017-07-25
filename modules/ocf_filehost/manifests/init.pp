class ocf_filehost {
  package {
    'nfs-kernel-server':
  } ->
  augeas { '/etc/default/nfs-kernel-server':
    lens    => 'Shellvars.lns',
    incl    => '/etc/default/nfs-kernel-server',
    # Increase number of NFS threads.
    changes =>  ['set RPCNFSDCOUNT 32'],
  } ~>
  file { '/etc/exports':
    source => 'puppet:///modules/ocf_filehost/exports',
  } ~>
  service { 'nfs-kernel-server':; }
}
