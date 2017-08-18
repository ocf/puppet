class ocf_filehost {
  package { 'quotatool':; }

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
  ocf::systemd::override { 'nfs-kernel-server-grace-period':
    unit    => 'nfs-server.service',
    # Decrease the grace period (time from server start until clients are
    # allowed to start reading/writing files) from 90 seconds to 10 seconds.
    #
    # It's unlikely for us to have a 10+ second netsplit, so this is reasonably
    # safe. This greatly reduces downtime during NFS restarts.
    #
    # The environment file lets us override the number of threads, but not the
    # grace period :\
    content => "[Service]\nExecStart=\nExecStart=/usr/sbin/rpc.nfsd -G 10 -- \$RPCNFSDARGS\n",
  } ~>
  service { 'nfs-server':; }
}
