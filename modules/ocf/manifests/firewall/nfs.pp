class ocf::firewall::nfs {
  ensure_resources('service', {
    'nfs-config' => {},
    'rpcbind'    => {},
    'quotarpc'   => {},
    'nfs-server' => {},
  })

  augeas {
    default:
      require => Package['nfs-kernel-server'];

    'Set rpc.statd ports':
      lens    => 'Shellvars.lns',
      incl    => '/etc/default/nfs-common',
      changes => "set STATDOPTS '\"--port 32765 --outgoing-port 32766\"'";

    'Set rpc.rquotad port':
      lens    => 'Shellvars.lns',
      incl    => '/etc/default/quota',
      changes => "set RPCRQUOTADOPTS '\"-p 32769\"'",
      notify  => Service['quotarpc'];

    'Set nfs-kernel-server port':
      lens    => 'Shellvars.lns',
      incl    => '/etc/default/nfs-kernel-server',
      changes => "set RPCMOUNTDOPTS '\"-p 32767\"'",
      notify  => Service['nfs-server'];
  } ~>
  # Make systemd re"compile" the NFS server config
  Service['nfs-config'] ~>
  Service['rpcbind']

  Service['rpcbind'] -> Service['quotarpc']
  Service['rpcbind'] -> Service['nfs-server']

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
