class ocf_irc::nodejs::webirc {
  package {
    'thelounge':
      require => [Package['nodejs'], Apt::Key['nodejs']];
  }

  $webirc_fqdn = $::hostname ? {
    /^dev-/ => 'dev-irc.ocf.berkeley.edu',
    default => 'irc.ocf.berkeley.edu',
  }

  file {
    '/etc/thelounge':
      ensure => directory;

    '/etc/thelounge/config.js':
      source  => 'puppet:///modules/ocf_irc/thelounge-conf.js',
      require => File['/etc/thelounge'],
      notify  => Service['thelounge'];
  }

  ocf::systemd::service { 'thelounge':
    source  => 'puppet:///modules/ocf_irc/thelounge.service',
    require => [
      Package['thelounge'],
      File['/etc/thelounge/config.js'],
    ],
  }

  # Nginx is used to proxy and to supply a HTTP -> HTTPS redirect
  class { 'nginx':
    manage_repo => false,
    confd_purge => true,
    vhost_purge => true,
  }

  nginx::resource::upstream { 'thelounge':
    members => ['localhost:9000'];
  }

  $ssl_options = {
    ssl         => true,
    ssl_cert    => "/etc/ssl/private/${::fqdn}.bundle",
    ssl_key     => "/etc/ssl/private/${::fqdn}.key",
    ssl_dhparam => '/etc/ssl/dhparam.pem',

    add_header => {
      'Strict-Transport-Security' => 'max-age=31536000',
    },
  }

  nginx::resource::vhost {
    $webirc_fqdn:
      server_name => [$webirc_fqdn],
      proxy       => 'http://thelounge',

      * => $ssl_options,

      rewrite_to_https => true;

    "${webirc_fqdn}-redirect":
      # Needs a www_root even though we just redirect
      www_root => '/var/www',

      server_name => [
        $::hostname,
        $::fqdn
      ],

      * => $ssl_options,

      vhost_cfg_append => {
        'return' => "301 https://${webirc_fqdn}\$request_uri"
      };
  }
}
