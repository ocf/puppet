# ocfweb consumed several other sites (accounts, wiki, hello), so we want to
# redirect those sites to the appropriate pages on ocfweb.
class ocf_www::site::ocfweb_redirects {
  # accounts
  $accounts_canonical_url = $::dev_config ? {
    true  => 'https://dev-accounts.ocf.berkeley.edu/'
    false => 'https://accounts.ocf.berkeley.edu/'
  }

  apache::vhost { 'accounts':
    servername    => 'accounts.ocf.berkeley.edu',
    serveraliases => ['dev-accounts.ocf.berkeley.edu'],
    port          => 443,
    docroot       => '/var/www/html',

    ssl           => true,
    ssl_key       => "/etc/ssl/private/${::fqdn}.key",
    ssl_cert      => "/etc/ssl/private/${::fqdn}.crt",
    ssl_chain     => '/etc/ssl/certs/incommon-intermediate.crt',

    rewrites      => [
      {rewrite_rule => '^/(change-password(/.*)?)?$ https://www.ocf.berkeley.edu/account/password [R=301,L]'},
      {rewrite_rule => '^/commands(/.*)?$ https://www.ocf.berkeley.edu/account/commands [R=301,L]'},
      {rewrite_rule => '^/request-account(/.*)?$ https://www.ocf.berkeley.edu/account/register [R=301,L]'},
      {rewrite_rule => '^/request-vhost(/.*)?$ https://www.ocf.berkeley.edu/account/vhost/ [R=301,L]'},
      {rewrite_rule => '^.*$ https://www.ocf.berkeley.edu/'},
    ],
    headers       => ['always set Strict-Transport-Security max-age=31536000'],
  }

  apache::vhost { 'accounts-http-redirect':
    servername      => 'accounts.ocf.berkeley.edu',
    serveraliases   => [
      'dev-accounts',
      'dev-accounts.ocf.berkeley.edu',
      'accounts',
    ],
    port            => 80,
    docroot         => '/var/www/html',

    redirect_status => 301,
    redirect_dest   => $accounts_canonical_url;
  }

  # wiki
  $wiki_canonical_url = $::dev_config ? {
    true  => 'https://dev-wiki.ocf.berkeley.edu/'
    false => 'https://wiki.ocf.berkeley.edu/'
  }

  apache::vhost { 'wiki':
    servername    => 'wiki.ocf.berkeley.edu',
    serveraliases => ['dev-wiki.ocf.berkeley.edu'],
    port          => 443,
    docroot       => '/var/www/html',

    ssl           => true,
    ssl_key       => "/etc/ssl/private/${::fqdn}.key",
    ssl_cert      => "/etc/ssl/private/${::fqdn}.crt",
    ssl_chain     => '/etc/ssl/certs/incommon-intermediate.crt',

    rewrites      => [
      {rewrite_rule => '^/(.*)$ https://www.ocf.berkeley.edu/docs/$1 [R=301]'},
    ],
    headers       => ['always set Strict-Transport-Security max-age=31536000'],
  }

  apache::vhost { 'wiki-http-redirect':
    servername      => 'wiki.ocf.berkeley.edu',
    serveraliases   => [
      'dev-wiki',
      'dev-wiki.ocf.berkeley.edu',
      'wiki',
    ],
    port            => 80,
    docroot         => '/var/www/html',

    redirect_status => 301,
    redirect_dest   => $wiki_canonical_url;
  }

  # hello
  $hello_canonical_url = $::dev_config ? {
    true  => 'https://dev-hello.ocf.berkeley.edu/'
    false => 'https://hello.ocf.berkeley.edu/'
  }

  apache::vhost { 'hello':
    servername    => 'hello.ocf.berkeley.edu',
    serveraliases => [
      'dev-hello.ocf.berkeley.edu',
      'dev-staff.ocf.berkeley.edu',
      'staff.ocf.berkeley.edu',
    ],
    port          => 443,
    docroot       => '/var/www/html',

    ssl           => true,
    ssl_key       => "/etc/ssl/private/${::fqdn}.key",
    ssl_cert      => "/etc/ssl/private/${::fqdn}.crt",
    ssl_chain     => '/etc/ssl/certs/incommon-intermediate.crt',

    rewrites      => [
      {rewrite_rule => '^/lab.html$ https://www.ocf.berkeley.edu/about/lab/open-source [R=301,L]'},
      {rewrite_rule => '^.*$ https://www.ocf.berkeley.edu/about/staff [R=301]'},
    ],
    headers       => ['always set Strict-Transport-Security max-age=31536000'],
  }

  apache::vhost { 'hello-http-redirect':
    servername      => 'hello.ocf.berkeley.edu',
    serveraliases   => [
      'dev-hello',
      'dev-hello.ocf.berkeley.edu',
      'dev-staff.ocf.berkeley.edu',
      'hello',
      'staff.ocf.berkeley.edu',
    ],
    port            => 80,
    docroot         => '/var/www/html',

    redirect_status => 301,
    redirect_dest   => $hello_canonical_url;
  }
}
