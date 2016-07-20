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
      content => template('ocf_irc/thelounge-conf.js.erb'),
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

  class { 'nginx':
    manage_repo => false,
    confd_purge => true,
    vhost_purge => true,
  }

  nginx::resource::upstream { 'thelounge':
    members => ['localhost:9000'];
  }

  nginx::resource::vhost {
    $webirc_fqdn:
      server_name => [$webirc_fqdn],
      proxy       => 'http://thelounge',

      ssl         => true,
      ssl_cert   => "/etc/ssl/private/${::fqdn}.bundle",
      ssl_key    => "/etc/ssl/private/${::fqdn}.key",

      add_header => {
        'Strict-Transport-Security' => 'max-age=31536000',
      },

      rewrite_to_https => true;
  }
}
