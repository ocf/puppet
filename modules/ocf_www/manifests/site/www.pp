# www.ocf.berkeley.edu (main website and userdirs)
#
# www is complicated; the difficult requirements are:
#
#   * Non-user resources (not matching the /~user/ pattern) should be proxied
#     to ocfweb.
#
#   * Users need to be able to run CGI and PHP under /~user/ as their own
#     user account.
#
#   * Mastodon needs to control .well-known/host-meta to shorten Mastodon
#     identifiers
class ocf_www::site::www {
  include apache::mod::actions
  include apache::mod::alias
  include apache::mod::expires
  include apache::mod::headers
  include apache::mod::include
  include apache::mod::proxy
  include apache::mod::proxy_http
  include apache::mod::rewrite
  include apache::mod::status
  include ocf_www::mod::cgi
  include ocf_www::mod::fcgid
  include ocf_www::mod::ocfdir
  include ocf_www::mod::php
  include ocf_www::mod::suexec

  file {
    ['/var/www/html/.well-known', '/var/www/html/.well-known/matrix']:
      ensure => 'directory';
    '/var/www/html/.well-known/matrix/server':
      source => 'puppet:///modules/ocf_www/matrix-server';
    '/var/www/html/.well-known/matrix/client':
      source => 'puppet:///modules/ocf_www/matrix-client';
  }

  # TODO: dev-death should add a robots.txt disallowing everything
  $www_options = {
    servername          => 'www.ocf.berkeley.edu',
    serveraliases       => ['dev-www.ocf.berkeley.edu'],
    docroot             => '/services/http/users',

    proxy_preserve_host => true,

    aliases             => [
      {
        alias => '/.well-known/matrix/server',
        path  => '/var/www/html/.well-known/matrix/server',
      },
      {
        alias => '/.well-known/matrix/client',
        path  => '/var/www/html/.well-known/matrix/client',
      },
    ],

    rewrites            => [
      {
        comment      => 'redirect .well-known/host-meta to mastodon',
        rewrite_rule => '/.well-known/host-meta https://mastodon.ocf.berkeley.edu/.well-known/host-meta',
      },
      {
        comment      => 'proxy to ocfweb',
        rewrite_cond => [
          # ...but not if it's a userdir
          '%{REQUEST_URI} !^/~',
          # ...and not if it's a special Apache thing (e.g. autoindex icons)
          '%{REQUEST_URI} !^/icons/',
          # ...hide ocfweb metrics
          '%{REQUEST_URI} !^/metrics',
          # ...and not if it's the matrix well-known file
          '%{REQUEST_URI} !^/\.well-known/matrix',
        ],
        rewrite_rule => '^/(.*)$ http://lb-81.ocf.berkeley.edu/$1 [P]',
      }
    ],

    directories         => [
      {
        path            => '/.well-known/matrix/client',
        provider        => 'location',
        custom_fragment => '
            Header set Access-Control-Allow-Origin "*"
        ',
      },
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
        path       => '\.(php[3457]?|phtml|fcgi)$',
        provider   => 'filesmatch',
        sethandler => 'fcgid-script',
      },
      {
        # XXX: Strip OCFWEB_* cookies before we hit userdirs so that they
        # cannot steal other peoples sessions.
        path            => '/',
        provider        => 'directories',
        request_headers => 'edit* Cookie (;?\s*OCFWEB_.+?)=.+?(;|$) $1=REMOVED$2',
      }
    ],

    custom_fragment     => '
      # Trust X-Forwarded-Proto from nginx so %{HTTPS} works in userdirs
      SetEnvIf X-Forwarded-Proto "https" HTTPS=on

      UserDir /services/http/users/
      UserDir disabled root
    ',
  }

  apache::vhost { 'www-backend':
    * => $www_options,
  }

  # canonical redirects
  $canonical_url = $::host_env ? {
    'dev'  => 'https://dev-www.ocf.berkeley.edu$1',
    'prod' => 'https://www.ocf.berkeley.edu$1',
  }

  $https_redirect_options = {
    servername           => 'ocf.berkeley.edu',
    serveraliases        => [
      'dev-ocf.berkeley.edu',
      'secure.ocf.berkeley.edu',
      $::fqdn,
    ],
    directories          => [
      {
        path            => '/.well-known/matrix/client',
        provider        => 'location',
        custom_fragment => '
            Header set Access-Control-Allow-Origin "*"
        ',
      },
    ],
    docroot              => '/var/www/html',
    redirectmatch_status => '301',
    # ugly exceptions
    redirectmatch_regexp => '^((?!\/\.well-known\/matrix\/(client|server)).*)',
    redirectmatch_dest   => $canonical_url,
  }

  apache::vhost { 'www-https-redirect-backend':
    * => $https_redirect_options,
  }
}
