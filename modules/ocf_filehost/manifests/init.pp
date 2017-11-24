class ocf_filehost {
  package { ['quotatool', 'nfs-kernel-server']:; }

  file { '/etc/exports':
    source  => 'puppet:///modules/ocf_filehost/exports',
    require => Package['nfs-kernel-server'],
  }

  augeas { '/etc/default/nfs-common':
    lens    => 'Shellvars.lns',
    incl    => '/etc/default/nfs-common',
    changes => "set STATDOPTS '\"--port 32765 --outgoing-port 32766\"'",
  }

  augeas { '/etc/default/quota':
    lens    => 'Shellvars.lns',
    incl    => '/etc/default/quota',
    changes => "set RPCRQUOTADOPTS '\"-p 32769\"'",
  }

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
      # NFS port options for firewall
      "set RPCMOUNTDOPTS '\"-p 32767\"'",
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

  # Firewall Rules #

  # Allow NFS
  ocf::firewall::firewall46 {
    '101 allow nfs':
      opts => {
        chain  => 'PUPPET-INPUT',
        proto  => 'tcp',
        dport  => 2049,
        action => 'accept',
      };
  }

  # Allow SunRPC
  ocf::firewall::firewall46 {
    '101 allow sunrpc':
      opts => {
        chain  => 'PUPPET-INPUT',
        proto  => ['tcp', 'udp'],
        dport  => 111,
        action => 'accept',
      };
  }

  # Allow statd, mountd and quotad RPC services
  ocf::firewall::firewall46 {
    '101 allow nfs rpc services':
      opts => {
        chain  => 'PUPPET-INPUT',
        proto  => ['tcp', 'udp'],
        dport  => '32764-32769',
        action => 'accept',
      };
  }
}
