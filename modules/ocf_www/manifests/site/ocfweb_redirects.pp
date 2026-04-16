# ocfweb consumed several other sites (accounts, wiki, hello), so we want to
# redirect those sites to the appropriate pages on ocfweb.
class ocf_www::site::ocfweb_redirects {
  # accounts
  $accounts_options = {
    ip            => '127.0.0.1',
    port          => $ocf_www::backend_port,
    servername    => 'accounts.ocf.berkeley.edu',
    serveraliases => ['dev-accounts.ocf.berkeley.edu'],
    docroot       => '/var/www/html',

    rewrites      => [
      {rewrite_rule => '^/(change-password(/.*)?)?$ https://www.ocf.berkeley.edu/account/password [R=301,L]'},
      {rewrite_rule => '^/commands(/.*)?$ https://www.ocf.berkeley.edu/account/commands [R=301,L]'},
      {rewrite_rule => '^/request-account(/.*)?$ https://www.ocf.berkeley.edu/account/register [R=301,L]'},
      {rewrite_rule => '^/request-vhost(/.*)?$ https://www.ocf.berkeley.edu/account/vhost/ [R=301,L]'},
      {rewrite_rule => '^.*$ https://www.ocf.berkeley.edu/'},
    ],
  }

  apache::vhost { 'accounts-backend':
    * => $accounts_options,
  }

  # wiki
  $wiki_options = {
    ip            => '127.0.0.1',
    port          => $ocf_www::backend_port,
    servername    => 'wiki.ocf.berkeley.edu',
    serveraliases => ['dev-wiki.ocf.berkeley.edu'],
    docroot       => '/var/www/html',

    rewrites      => [
      {rewrite_rule => '^/(.*)$ https://www.ocf.berkeley.edu/docs/$1 [R=301]'},
    ],
  }

  apache::vhost { 'wiki-backend':
    * => $wiki_options,
  }

  # hello
  $hello_options = {
    ip            => '127.0.0.1',
    port          => $ocf_www::backend_port,
    servername    => 'hello.ocf.berkeley.edu',
    serveraliases => [
      'dev-hello.ocf.berkeley.edu',
      'dev-staff.ocf.berkeley.edu',
      'staff.ocf.berkeley.edu',
    ],
    docroot       => '/var/www/html',

    rewrites      => [
      {rewrite_rule => '^/lab.html$ https://www.ocf.berkeley.edu/about/lab/open-source [R=301,L]'},
      {rewrite_rule => '^.*$ https://www.ocf.berkeley.edu/about/staff [R=301]'},
    ],
  }

  apache::vhost { 'hello-backend':
    * => $hello_options,
  }
}
