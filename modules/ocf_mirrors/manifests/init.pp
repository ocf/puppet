class ocf_mirrors {
  require ocf::ssl::default
  require ocf::packages::rsync
  include ocf_mirrors::ftp
  include ocf_mirrors::rsync
  include ocf_mirrors::firewall_input
  # projects
  include ocf_mirrors::projects::apache
  include ocf_mirrors::projects::alpine
  include ocf_mirrors::projects::archlinux
  include ocf_mirrors::projects::archlinuxcn
  include ocf_mirrors::projects::centos
  include ocf_mirrors::projects::centos_altarch
  include ocf_mirrors::projects::centos_debuginfo
  include ocf_mirrors::projects::debian
  include ocf_mirrors::projects::devuan
  include ocf_mirrors::projects::emacs_lisp_archive
  include ocf_mirrors::projects::fedora
  include ocf_mirrors::projects::finnix
  include ocf_mirrors::projects::freebsd
  include ocf_mirrors::projects::gnome
  include ocf_mirrors::projects::gnu
  include ocf_mirrors::projects::kali
  include ocf_mirrors::projects::kde
  include ocf_mirrors::projects::kde_applicationdata
  include ocf_mirrors::projects::manjaro
  include ocf_mirrors::projects::openbsd
  include ocf_mirrors::projects::parrot
  include ocf_mirrors::projects::puppetlabs
  include ocf_mirrors::projects::qt
  include ocf_mirrors::projects::raspbian
  include ocf_mirrors::projects::raspi
  include ocf_mirrors::projects::tails
  include ocf_mirrors::projects::trisquel
  include ocf_mirrors::projects::ubuntu
  package {
      [
        'prometheus-nginx-exporter',
      ]:;
    }
  # Prometheus user needed for the prometheus-apache-exporter daemon,
  # which runs as user "prometheus"
  user {
    'prometheus':
      comment  => 'prometheus user for running exporters',

      # Set to have no password, only allow key-based login
      password => '*',
  }
  user { 'mirrors':
    comment  => 'OCF Mirroring',
    home     => '/opt/mirrors',
    shell    => '/bin/bash',

    # Set to have no password, only allow key-based login
    password => '*',
  }

  class {
    '::nginx':
      manage_repo             => false,
      include_modules_enabled => true,
      http_raw_append         => @(END);
      gzip on;
      sendfile_max_chunk 20m;
      log_format main '$remote_addr - $remote_user [$time_local] '
                '"$request" $status $body_bytes_sent "$http_referer" '
                '"$http_user_agent" rt=$request_time $request_length $bytes_sent';

      END
  }
  $ocfstats_password = lookup('ocfstats::mysql::password')

  file {
    ['/opt/mirrors', '/opt/mirrors/ftp', '/opt/mirrors/project', '/opt/mirrors/bin']:
      ensure  => directory,
      mode    => '0755',
      owner   => mirrors,
      group   => mirrors,
      require => User['mirrors'];

    '/opt/mirrors/ftp/README.html':
      source => 'puppet:///modules/ocf_mirrors/README.html',
      owner  => mirrors,
      group  => mirrors;

    '/opt/mirrors/ftp/robots.txt':
      source => 'puppet:///modules/ocf_mirrors/robots.txt',
      owner  => mirrors,
      group  => mirrors;

    '/var/log/rsync':
      ensure => directory;
  }
  nginx::resource::server { 'mirrors.ocf.berkeley.edu':
    listen_port         => 80,
    ssl_port            => 443,
    listen_options      => 'default_server',
    www_root            => '/opt/mirrors/ftp',
    ssl                 => true,
    http2               => on,
    ssl_cert            => "/etc/ssl/private/${::fqdn}.bundle",
    ssl_key             => "/etc/ssl/private/${::fqdn}.key",
    ipv6_enable         => true,
    ipv6_listen_port    => 80,
    ipv6_listen_options => 'default_server',
    format_log          => 'main',
    raw_append          => @(END),
      fancyindex on;
      fancyindex_exact_size off;
      if ($http_user_agent ~ "(MSIE 7\.0; Windows NT (6\.1|6\.2)|Chrome\/49\.0|Chrome\/67\.0|Edg\/85\.0\.537\.0)") {
        return 403;
      }
      END
  }
  nginx::resource::location { '= /':
    ensure     => present,
    server     => 'mirrors.ocf.berkeley.edu',
    ssl        => true,
    www_root   => '/opt/mirrors/ftp',
    raw_append => @(END),
      fancyindex_header README.html;
      END
  }
  nginx::resource::location { '~ ^/tails':
    server      => 'mirrors.ocf.berkeley.edu',
    ssl         => true,
    index_files => undef,
    raw_append  => @(END),
      etag off;
      END
  }
  nginx::resource::location { '~ /\.(?!well-known).*':
    ensure     => present,
    server     => 'mirrors.ocf.berkeley.edu',
    ssl        => true,
    raw_append => @(END),
      deny all;
      END
  }
  nginx::resource::server { 'mirrors.berkeley.edu':
    listen_port         => 80,
    ipv6_enable         => true,
    ipv6_listen_port    => 80,
    www_root            => '/var/www',
    location_cfg_append => {
      'rewrite' => '^ http://mirrors.ocf.berkeley.edu permanent'
    }
  }
  nginx::resource::server { '_':
    listen_ip           => '127.0.0.1',
    listen_port         => 8080,
    ipv6_listen_options => 'default_server',
    listen_options      => 'default_server',
    ipv6_enable         => true,
    ipv6_listen_ip      => '::1',
    ipv6_listen_port    => 8080,
    www_root            => '/var/www',
  }
  nginx::resource::location { '= /stub_status':
      ensure     => present,
      server     => '_',
      raw_append => @(END),
        stub_status;
        END
    }

  file { '/opt/mirrors/bin/report-sizes':
    source => 'puppet:///modules/ocf_mirrors/report-sizes',
    mode   => '0755',
  } ->
  cron { 'report-sizes':
    command => '/opt/mirrors/bin/report-sizes',
    special => 'daily',
  }

  file { '/opt/mirrors/bin/healthcheck':
    source => 'puppet:///modules/ocf_mirrors/healthcheck',
    owner  => 'mirrors',
    group  => 'mirrors',
    mode   => '0755',
  }

  file {
    '/opt/ocfstats-password':
      content   => lookup('ocfstats::mysql::password'),
      mode      => '0600',
      owner     => 'root',
      group     => 'root',
      show_diff => false;

    '/usr/local/sbin/collect-mirrors-stats':
      source => 'puppet:///modules/ocf_mirrors/collect-mirrors-stats',
      mode   => '0755';
  } ->
  cron { 'mirrors-stats':
    command     => '/usr/local/sbin/collect-mirrors-stats --quiet --no-dry-run',
    minute      => 0,
    hour        => 0,
    environment => ['OCFSTATS_PWD__FILE=/opt/ocfstats-password'];
  }

  package { ['python3-prometheus-client']: }
  File<|title == '/srv/prometheus'|> {
    owner => 'mirrors',
    group => 'mirrors',
  }
}
