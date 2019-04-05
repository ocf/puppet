class ocf_kubernetes::master::loadbalancer {
  include ocf::firewall::allow_web

  $extra_aliases = {
    'pma'      => ['phpmyadmin'],
    'metabase' => ['mb'],
    'sourcegraph' => ['sg'],
  }

  $kubernetes_worker_nodes = lookup('kubernetes::worker_nodes')

  # At any given time, only one kubernetes master will hold
  # the first IP. The master holding the IP will handle all
  # nginx requests and send them into the cluster.
  #
  # TODO: If we expose TCP services, we may need to add more.
  #
  # IPv6 addresses have to be specified separately as they cannot be in the vrrp
  # packet together (keepalived 1.2.20+) so they need to be in a
  # virtual_ipaddress_excluded block instead.
  $virtual_addresses = [
    # Primary load balancer IP (v4)
    '169.229.226.79',
  ]
  $virtual_addresses_v6 = [
    # Primary load balancer IP (v6)
    '2607:f140:8801::1:79',
  ]
  $keepalived_secret = lookup('kubernetes::keepalived::secret')

  package { 'keepalived':; } ->
  file { '/etc/keepalived/keepalived.conf':
    content => template('ocf_kubernetes/master/loadbalancer/keepalived.conf.erb'),
    mode    => '0400',
  } ~>
  service { 'keepalived': }

  $vip = 'lb-kubernetes'

  class { 'ocf_kubernetes::master::loadbalancer::ssl':
    vip => $vip,
  }

  # Redirect from "cname.ocf.io" to "cname.ocf.berkeley.edu" for each cname.
  # Don't include wildcard entries.
  $cnames = ldap_attr($vip, 'dnsCname', true).filter |$cname| { $cname !~ /\*/ }

  package { ['nginx-extras']:; }

  class { 'nginx':
    manage_repo  => false,
    confd_purge  => true,
    server_purge => true,

    require      => Package['nginx-extras'],
  }

  $upstream_workers = Hash.new($kubernetes_worker_nodes.map |String $worker| {
    [
      "${worker}:31234",
      {
        server => $worker,
        port   => 31234,
      },
    ]
  })
  nginx::resource::upstream {
    'kubernetes':
      members => $upstream_workers
  }

  nginx::resource::server {
    'ingress-proxy':
      server_name         => ['_'],
      proxy               => 'http://kubernetes',
      proxy_set_header    => [
        'Host $host',
        'X-Forwarded-For $proxy_add_x_forwarded_for',
        'X-Forwarded-Proto $scheme',
        'X-Real-IP $remote_addr',
      ],

      listen_port         => 443,
      listen_options      => 'default_server',
      ipv6_listen_options => 'default_server',
      ssl                 => true,
      ssl_cert            => "/etc/ssl/private/${::fqdn}.bundle",
      ssl_key             => "/etc/ssl/private/${::fqdn}.key",
      ssl_dhparam         => '/etc/ssl/dhparam.pem',

      add_header          => {
        'Strict-Transport-Security' =>  'max-age=31536000',
      };

    'ingress-proxy-redirect':
      server_name         => ['_'],
      listen_port         => 80,
      listen_options      => 'default_server',
      ipv6_listen_options => 'default_server',
      server_cfg_append   => {
        'return' => '301 https://$host$request_uri'
      };

    'downstream-proxy':
      # This is used for hosts that don't directly point to lb-kubernetes, but
      # are instead reverse proxied from another server (like puppet, www, irc)
      # This points to the same backend as other requests, but doesn't handle
      # alias redirects or TLS termination. In these cases, TLS is handled by
      # the upstream reverse proxy.
      server_name         => ['_'],
      listen_port         => 4080,
      ipv6_listen_port    => 4080,
      listen_options      => 'default_server',
      ipv6_listen_options => 'default_server',
      proxy               => 'http://kubernetes',
      proxy_set_header    => [
        'Host $host',
      ];
  }

  # Redirect from "cname.ocf.io" to "cname.ocf.berkeley.edu" for each cname.
  $cnames.each |$domain| {
    $main_fqdns = prefix(['.ocf.io', ''], $domain)

    # Get the list of aliases for this name, or an empty list if there are none
    $extra_names = flatten([$extra_aliases[$domain]]).filter |$val| {
      $val =~ NotUndef
    }

    # Append .ocf.berkeley.edu, .ocf.io, and empty string for each of the extra aliases
    $extra_fqdns = flatten($extra_names.map |$name| {
      prefix(['.ocf.berkeley.edu', '.ocf.io', ''], $name)
    })

    $redir_fqdns = $main_fqdns + $extra_fqdns

    notify {$redir_fqdns:}

    nginx::resource::server {
      "${domain}-http-direct":
        server_name       => $redir_fqdns,
        listen_port       => 80,
        server_cfg_append => {
          'return' => "301 https://${domain}.ocf.berkeley.edu\$request_uri"
        };

      "${domain}-alias-redirect":
        server_name       => $redir_fqdns,
        listen_port       => 443,
        ssl               => true,
        ssl_cert          => "/etc/ssl/private/${::fqdn}.bundle",
        ssl_key           => "/etc/ssl/private/${::fqdn}.key",
        ssl_dhparam       => '/etc/ssl/dhparam.pem',

        add_header        => {
          'Strict-Transport-Security' =>  'max-age=31536000',
        },

        server_cfg_append => {
          'return' => "301 https://${domain}.ocf.berkeley.edu\$request_uri"
        };
    }
  }
}
