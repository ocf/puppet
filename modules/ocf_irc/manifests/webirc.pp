class ocf_irc::webirc {

  $webirc_fqdn = $::host_env ? {
    'dev'  => 'dev-irc.ocf.berkeley.edu',
    'prod' => 'irc.ocf.berkeley.edu',
  }

  # Nginx is used to proxy to Kubernetes and to supply a HTTP -> HTTPS redirect
  class { 'nginx':
    manage_repo  => false,
    confd_purge  => true,
    server_purge => true,
  }

  # Restart nginx if any cert changes occur
  Class['ocf::ssl::default'] ~> Class['Nginx::Service']

  ocf::nginx_proxy { $webirc_fqdn:
    server_aliases => [
      $::hostname,
      $::fqdn,
    ],
    proxy          => 'http://lb-kubernetes.ocf.berkeley.edu:4080',
    ssl            => true,
  }
}
