# The 503 "website unavailable" page, shown on disabled vhosts and and any
# unrecognized Host headers.
#
# These are the *default* vhosts. Note that there's a good chance the HTTPS
# vhost will be served with a certificate warning (including for disabled
# vhosts), since we aren't able/willing to maintain certificates for them
# easily.
class ocf_www::site::unavailable {
  file { '/srv/unavailable':
    ensure => directory,
  }

  file { '/srv/unavailable/unavailable.html':
    source => 'puppet:///modules/ocf_www/unavailable.html',
  }

  $options = {
    # priority 10 so this is the default vhost
    priority   => 10,

    servername => 'unavailable.ocf.berkeley.edu',
    docroot    => '/srv/unavailable',

    rewrites   => [
      {
        rewrite_cond => [
          # Don't keep redirecting forever, only if it's not already a 503
          '%{ENV:REDIRECT_STATUS} !=503',

          # Don't redirect the server-status page (used by munin for stats)
          '%{REQUEST_URI} !^/server-status',
        ],
        rewrite_rule => '.* - [L,R=503]',
      },
    ],

    error_documents => [
      {error_code => 503, document => '/unavailable.html'},
    ],
  }

  apache::vhost { 'unavailable':
    *    => $options,
    port => 80,
  }

  apache::vhost { 'https-unavailable':
    *         => $options,
    port      => 443,

    ssl       => true,
    ssl_key   => "/etc/ssl/private/${::fqdn}.key",
    ssl_cert  => "/etc/ssl/private/${::fqdn}.crt",
    ssl_chain => '/etc/ssl/certs/incommon-intermediate.crt',
  }
}
