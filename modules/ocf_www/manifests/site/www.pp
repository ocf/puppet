# www.ocf.berkeley.edu (main website and userdirs)
#
# www is complicated; the difficult requirements are:
#
#   * Non-user resources (not matching the /~user/ pattern) should be proxied
#     to ocfweb.
#
#   * Users need to be able to run CGI and PHP under /~user/ as their own
#     user account.
class ocf_www::site::www {
  include apache::mod::actions
  include apache::mod::alias
  include apache::mod::expires
  include apache::mod::headers
  include apache::mod::include
  include apache::mod::proxy
  include apache::mod::proxy_http
  include apache::mod::rewrite
  include apache::mod::suexec
  include ocf_www::mod::cgi
  include ocf_www::mod::fastcgi
  include ocf_www::mod::ocfdir
  include ocf_www::mod::php

  # TODO: dev-death should add a robots.txt disallowing everything
  apache::vhost { 'www':
    servername      => 'www.ocf.berkeley.edu',
    serveraliases   => ['dev-www.ocf.berkeley.edu'],
    port            => 443,
    docroot         => '/var/www/html',

    ssl             => true,
    ssl_key         => "/etc/ssl/private/${::fqdn}.key",
    ssl_cert        => "/etc/ssl/private/${::fqdn}.crt",
    ssl_chain       => '/etc/ssl/certs/incommon-intermediate.crt',

    headers         => ['set Strict-Transport-Security max-age=31536000'],

    rewrites        => [
      {
        comment      => 'proxy to ocfweb',
        rewrite_cond => [
          # ...but not if it's a userdir
          '%{REQUEST_URI} !^/~',
          # ...and not if it's a special Apache thing (e.g. autoindex icons)
          '%{REQUEST_URI} !^/icons/',
        ],
        rewrite_rule => '^/(.*)$ http://ocfweb.ocf.berkeley.edu:8001/$1 [P]',
      }
    ],

    directories     => [
      {
        path           => '/services/http/users',
        provider       => 'directories',
        directoryindex => 'index.html index.cgi index.pl index.php index.xhtml index.htm index.shtm index.shtml',
        options        => [
          'ExecCGI',
          'FollowSymLinks',
          'IncludesNoExec',
          'Indexes',
          'MultiViews',
          'SymLinksIfOwnerMatch',
        ],
        allow_override => ['All'],
      },
      {
        path           => '\.(cgi|shtml|phtml|php)$',
        provider       => 'filesmatch',
        ssl_options    => '+StdEnvVars',
      },
    ],

    custom_fragment => '
      UserDir /services/http/users/
      UserDir disabled root
      ProxyPreserveHost on

      # TODO: puppet does not allow setting request_headers in directories, send a PR?
      <Directory />
        # XXX: Strip OCFWEB_* cookies before we hit userdirs so that they
        # cannot steal other peoples sessions.
        RequestHeader edit* Cookie (;?\s*OCFWEB_.+?)=.+?(;|$) $1=REMOVED$2
      </Directory>
    ',
  }

  # canonical redirects
  $canonical_url = $::hostname ? {
    /^dev-/ => 'https://dev-www.ocf.berkeley.edu/',
    default => 'https://www.ocf.berkeley.edu/',
  }

  apache::vhost {
    # redirect any HTTP -> canonical HTTPS
    'www-http-redirect':
      servername      => 'www.ocf.berkeley.edu',
      serveraliases   => [
        'www',
        'dev-www',
        'ocf.berkeley.edu',
        'dev-ocf.berkeley.edu',
        'secure',
        'secure.ocf.berkeley.edu',
        $::hostname,
        $::fqdn,
      ],
      port            => 80,
      docroot         => '/var/www/html',
      redirect_status => 301,
      redirect_dest   => $canonical_url;

    # redirect weird HTTPS -> canonical HTTPS
    'www-https-redirect':
      servername      => 'ocf.berkeley.edu',
      serveraliases   => ['dev-ocf.berkeley.edu', 'secure.ocf.berkeley.edu', $::fqdn],
      port            => 443,
      docroot         => '/var/www/html',
      redirect_status => 301,
      redirect_dest   => $canonical_url,

      ssl             => true,
      ssl_key         => "/etc/ssl/private/${::fqdn}.key",
      ssl_cert        => "/etc/ssl/private/${::fqdn}.crt",
      ssl_chain       => '/etc/ssl/certs/incommon-intermediate.crt';
  }
}
