class ocf_irc::webirc {

  $webirc_fqdn = $::dev_config ? {
    true  => 'dev-irc.ocf.berkeley.edu'
    false => 'irc.ocf.berkeley.edu'
  }

  # Nginx is used to proxy to Marathon and to supply a HTTP -> HTTPS redirect
  class { 'nginx':
    manage_repo => false,
    confd_purge => true,
    server_purge => true,
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

  nginx::resource::server {
    $webirc_fqdn:
      server_name      => [$webirc_fqdn],
      proxy            => 'https://thelounge.ocf.berkeley.edu',
      proxy_set_header => [
        'X-Forwarded-For $remote_addr',
        'Host thelounge.ocf.berkeley.edu',
      ],

      * => $ssl_options,

      ssl_redirect => true;

    "${webirc_fqdn}-redirect":
      # Needs a www_root even though we just redirect
      www_root => '/var/www',

      server_name => [
        $::hostname,
        $::fqdn
      ],

      * => $ssl_options,

      server_cfg_append => {
        'return' => "301 https://${webirc_fqdn}\$request_uri"
      };
  }
}
