class ocf_mirrors {
  user { 'mirrors':
    comment => 'OCF Mirroring',
    home    => '/opt/mirrors',
    groups  => ['sys'],
    shell   => '/bin/false',
    require => File['/opt/mirrors'];
  }

  file {
    ['/opt/mirrors', '/opt/mirrors/ftp', '/opt/mirrors/project']:
      ensure  => directory,
      mode    => 755,
      owner => mirrors,
      group => mirrors;
  }

  class { 'apache':
    default_vhost => false;
  }

  apache::vhost { 'mirrors.ocf.berkeley.edu':
    serveraliases   => ['mirrors'],
    port            => 80,
    docroot         => '/opt/mirrors/ftp',

    directories     => [{
      path          => '/opt/mirrors/ftp',
      options       => ['+Indexes', '+SymlinksIfOwnerMatch'],
      indexoptions  => ['NameWidth=*', '+SuppressDescription']
    }];
  }

  apache::vhost { 'mirrors.ocf.berkeley.edu-ssl':
    port            => 443,
    docroot         => '/opt/mirrors/ftp',

    directories     => [{
      path          => '/opt/mirrors/ftp',
      options       => ['+Indexes', '+SymlinksIfOwnerMatch'],
      index_options => ['NameWidth=*', '+SuppressDescription']
    }],

    ssl             => true,
    ssl_key         => "/etc/ssl/private/${::fqdn}.key",
    ssl_cert        => "/etc/ssl/private/${::fqdn}.crt",
    ssl_chain       => '/etc/ssl/certs/incommon-intermediate.crt';
  }
}
