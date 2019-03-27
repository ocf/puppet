class ocf_puppet::puppetboard {
  include ocf::firewall::allow_web

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

  # Restart nginx if any cert changes occur
  Class['ocf::ssl::default'] ~> Class['Nginx::Service']

  ocf::nginx_proxy { $puppet_fqdn:
    server_aliases => [
      'pb.ocf.berkeley.edu',
      'pb',
      'puppet',
      $::hostname,
      $::fqdn,
    ],
    proxy          => 'http://lb-kubernetes.ocf.berkeley.edu:4080',
    ssl            => true,
  }
}
