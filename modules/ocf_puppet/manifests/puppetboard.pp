class ocf_puppet::puppetboard {
  $puppet_fqdn = $::host_env ? {
    'dev'  => 'dev-puppet.ocf.berkeley.edu',
    'prod' => 'puppet.ocf.berkeley.edu',
  }

  # Nginx is used to proxy to Marathon and to supply a HTTP -> HTTPS redirect
  class { 'nginx':
    manage_repo  => false,
    confd_purge  => true,
    server_purge => true,
  }

  ocf::nginx_proxy { $puppet_fqdn:
    server_aliases => [
      'pb.ocf.berkeley.edu',
      'pb',
      'puppet',
      $::hostname,
      $::fqdn,
    ],
    proxy          => 'http://lb.ocf.berkeley.edu:10009',
    ssl            => true,
  }
}
