class ocf_jenkins::proxy {
  class { 'nginx':
    manage_repo   => false,
    confd_purge   => true,
    server_purge  => true,
    server_tokens => off,
  }

  ocf::nginx_proxy { 'jenkins.ocf.berkeley.edu':
    server_aliases => [
      $::hostname,
      $::fqdn
    ],
    ssl            => true,
    proxy          => 'http://localhost:8080',
    proxy_redirect => 'http://localhost:8080 https://jenkins.ocf.berkeley.edu',
  }
}
