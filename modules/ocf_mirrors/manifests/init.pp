class ocf_mirrors {
  include ocf_ssl

  include ftp
  include rsync

  # projects
  include apache
  include archlinux
  include debian
  include ubuntu

  user { 'mirrors':
    comment => 'OCF Mirroring',
    home    => '/opt/mirrors',
    groups  => ['sys'],
    shell   => '/bin/false',
    require => File['/opt/mirrors'];
  }

  file {
    ['/opt/mirrors', '/opt/mirrors/ftp', '/opt/mirrors/project']:
      ensure => directory,
      mode   => '0755',
      owner  => mirrors,
      group  => mirrors;

    '/opt/mirrors/ftp/README.html':
      source => 'puppet:///modules/ocf_mirrors/README.html',
      owner  => mirrors,
      group  => mirrors;
  }

  class { '::apache':
    default_vhost => false;
  }

  apache::vhost { 'mirrors.ocf.berkeley.edu':
    serveraliases   => ['mirrors'],
    port            => 80,
    docroot         => '/opt/mirrors/ftp',

    directories     => [{
      path          => '/opt/mirrors/ftp',
      options       => ['+Indexes', '+SymlinksIfOwnerMatch'],
      index_options => ['NameWidth=*', '+SuppressDescription']
    }],

    custom_fragment => "HeaderName README.html\nReadmeName FOOTER.html"
  }

  apache::vhost { 'mirrors.berkeley.edu':
    port            => 80,

    # we have to specify docroot even though we always redirect
    docroot         => '/var/www',

    redirect_source => '/',
    redirect_dest   => 'http://mirrors.ocf.berkeley.edu/',
    redirect_status => '301';
  }

  apache::vhost { 'mirrors.ocf.berkeley.edu-ssl':
    port            => 443,
    docroot         => '/opt/mirrors/ftp',

    directories     => [{
      path          => '/opt/mirrors/ftp',
      options       => ['+Indexes', '+SymlinksIfOwnerMatch'],
      index_options => ['NameWidth=*', '+SuppressDescription']
    }],

    custom_fragment => "HeaderName README.html\nReadmeName FOOTER.html",

    ssl             => true,
    ssl_key         => "/etc/ssl/private/${::fqdn}.key",
    ssl_cert        => "/etc/ssl/private/${::fqdn}.crt",
    ssl_chain       => '/etc/ssl/certs/incommon-intermediate.crt';
  }
}
