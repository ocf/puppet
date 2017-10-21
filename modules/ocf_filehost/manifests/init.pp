class ocf_filehost {
  package { ['quotatool', 'nfs-kernel-server']:; }

  file { '/etc/exports':
    source  => 'puppet:///modules/ocf_filehost/exports',
    require => Package['nfs-kernel-server'],
  }

  ocf::systemd::override { 'nfs-kernel-server-grace-period':
    # TODO: temporary, remove
    ensure => absent,
    unit   => 'nfs-server.service',
  } ~>
  augeas { '/etc/default/nfs-kernel-server':
    lens    => 'Shellvars.lns',
    incl    => '/etc/default/nfs-kernel-server',
    changes => [
      # Increase number of NFS threads.
      'set RPCNFSDCOUNT 32',

      # Decrease the grace period (time from server start until clients are
      # allowed to start reading/writing files) from 90 seconds to 10 seconds.
      #
      # It's unlikely for us to have a 10+ second netsplit, so this is reasonably
      # safe. This greatly reduces downtime during NFS restarts.
      "set RPCNFSDOPTS '\"-G 10\"'",
    ],
    require => Package['nfs-kernel-server'],
  } ~>
  service {
    # Make systemd re"compile" the NFS server config
    'nfs-config':;
  } ~>
  service {
    'nfs-server':
      subscribe => File['/etc/exports'],
  }
}
