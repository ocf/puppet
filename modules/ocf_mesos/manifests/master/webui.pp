class ocf_mesos::master::webui(
    $mesos_fqdn,
    $mesos_http_password,
    $mesos_agent_http_password,
    $marathon_fqdn,
    $marathon_http_password,
) {
  require ocf_ssl::default_bundle

  ocf_ssl::bundle { 'wildcard.agent.mesos.ocf.berkeley.edu':; }

  # We limit access to ocfroot only via PAM.
  file {
    '/opt/share/mesos-admin-groups':
      content => "ocfroot\n";

    '/opt/share/mesos-admin-users':
      content => "ocfdeploy\n";

    '/etc/pam.d/mesos_master_webui':
      source  => 'puppet:///modules/ocf_mesos/master/webui/mesos_master_webui',
      require => File[
        '/opt/share/mesos-admin-groups',
        '/opt/share/mesos-admin-users'
      ];
  }

  # We need the PAM authentication module, so install nginx-extras.
  ocf::repackage { 'nginx-extras':
    backport_on => jessie,
  }

  class { 'nginx':
    manage_repo  => false,
    confd_purge  => true,
    vhost_purge  => true,

    require => Ocf::Repackage['nginx-extras'],
  }

  nginx::resource::upstream {
    'mesos':
      members => ['localhost:5050'];

    'marathon':
      members => ['localhost:8080'];
  }

  $mesos_auth_header = base64('encode', "ocf:${mesos_http_password}", 'strict')
  $mesos_agent_auth_header = base64('encode', "ocf:${mesos_agent_http_password}", 'strict')
  $marathon_auth_header = base64('encode', "marathon:${marathon_http_password}", 'strict')

  $mesos_sub_filter = lookup('mesos_slaves').map |$slave| {
      "':5051\",\"hostname\":\"${slave}\"' ':443\",\"hostname\":\"${slave}.agent.mesos.ocf.berkeley.edu\"'"
  }

  nginx::resource::vhost {
    default:
      ssl_cert    => "/etc/ssl/private/${::fqdn}.bundle",
      ssl_key     => "/etc/ssl/private/${::fqdn}.key",
      ssl_dhparam => '/etc/ssl/dhparam.pem',
      add_header  => {
        'Strict-Transport-Security' => 'max-age=31536000',
      };

    # mesos
    'mesos':
      server_name => [$mesos_fqdn],
      proxy       => 'http://mesos',
      ssl         => true,
      listen_port => 443,

      # has a sensitive authorization header
      mode        => '0600',

      # Mesos will redirect to a URL like "//mesos5:5050" when redirecting to
      # the current leader; we want to remove the port and go to the HTTPS site
      # with the entire FQDN instead.
      proxy_redirect => '~^//mesos([0-9]+):5050 https://mesos$1.ocf.berkeley.edu/',

      raw_append => [
        'auth_pam "OCF Mesos Master";',
        'auth_pam_service_name mesos_master_webui;',
      ],

      proxy_set_header => [
        'X-Forwarded-Protocol $scheme',
        'X-Forwarded-For $proxy_add_x_forwarded_for',
        'Host $http_host',
        "Authorization 'Basic ${mesos_auth_header}'",
      ],

      require => File['/etc/pam.d/mesos_master_webui'];

    'mesos-https-leader':
      server_name => ['mesos.ocf.berkeley.edu'],

      # The mesos leader might change at any time, but nginx only resolves DNS on
      # startup. We use the hack of storing it in a variable to work around that.
      # https://github.com/ocf/puppet/issues/104
      proxy       => '$mesos_leader_upstream',

      ssl         => true,
      listen_port => 443,

      # has a sensitive authorization header
      mode        => '0600',

      raw_append => [
        'auth_pam "OCF Mesos Master";',
        'auth_pam_service_name mesos_master_webui;',

        'resolver ns.ocf.berkeley.edu;',
        'set $mesos_leader_upstream http://leader.mesos:5050;',
      ],

      location_cfg_append => {
        # Replace the agent hostnames with our own proxied versions.
        # This is what enables talking to the agents, and thus retrieving stdout/stderr from the UI.
        'proxy_set_header' => 'Accept-Encoding ""',  # prevent gzip
        'sub_filter_once' => 'off',
        'sub_filter' => $mesos_sub_filter,
        'sub_filter_types' => 'text/javascript',
      },

      proxy_set_header => [
        'X-Forwarded-Protocol $scheme',
        'X-Forwarded-For $proxy_add_x_forwarded_for',
        'Host $http_host',
        "Authorization 'Basic ${mesos_auth_header}'",
      ],

      require => File['/etc/pam.d/mesos_master_webui'];

    'mesos-http-redirect':
      # we have to specify www_root even though we always redirect/proxy
      www_root => '/var/www',

      server_name      => [$::hostname, $::fqdn, 'mesos', 'mesos.ocf.berkeley.edu'],
      vhost_cfg_append => {
        'return' => '301 https://mesos.ocf.berkeley.edu\$request_uri',
      };

    # marathon
    'marathon':
      server_name => ['marathon.ocf.berkeley.edu', $marathon_fqdn],
      proxy       => 'http://marathon',
      ssl         => true,
      listen_port => 443,

      # has a sensitive authorization header
      mode        => '0600',

      raw_append => [
        'auth_pam "OCF Marathon Master";',
        'auth_pam_service_name mesos_master_webui;',
      ],

      proxy_set_header => [
        'X-Forwarded-Protocol $scheme',
        'X-Forwarded-For $proxy_add_x_forwarded_for',
        'Host $http_host',
        "Authorization 'Basic ${marathon_auth_header}'",
      ],

      require => File['/etc/pam.d/mesos_master_webui'];

    'marathon-http-redirect':
      # we have to specify www_root even though we always redirect/proxy
      www_root => '/var/www',

      server_name      => ['marathon', 'marathon.ocf.berkeley.edu'],
      vhost_cfg_append => {
        'return' => '301 https://marathon.ocf.berkeley.edu\$request_uri',
      };
  }

  # Mesos agent proxies
  lookup('mesos_slaves').each |String $slave| {
    $host = "${slave}.agent.mesos.ocf.berkeley.edu"

    nginx::resource::upstream { "${slave}-agent":
      members => ["${slave}:5051"],
    }

    nginx::resource::vhost {
      "${slave}-agent":
        server_name => [$host],
        proxy       => "http://${slave}-agent",
        ssl         => true,
        ssl_cert    => '/etc/ssl/private/wildcard.agent.mesos.ocf.berkeley.edu.bundle',
        ssl_key     => '/etc/ssl/private/wildcard.agent.mesos.ocf.berkeley.edu.key',
        ssl_dhparam => '/etc/ssl/dhparam.pem',
        listen_port => 443,

        # has a sensitive authorization header
        mode        => '0600',

        raw_append => [
          'auth_pam "OCF Mesos Agent";',
          'auth_pam_service_name mesos_master_webui;',
        ],

        proxy_set_header => [
          'X-Forwarded-Protocol $scheme',
          'X-Forwarded-For $proxy_add_x_forwarded_for',
          'Host $http_host',
          "Authorization 'Basic ${mesos_agent_auth_header}'",
        ],

        require => [
          File['/etc/pam.d/mesos_master_webui'],
          Ocf_ssl::Bundle['wildcard.agent.mesos.ocf.berkeley.edu'],
        ];

      "${slave}-agent-http-redirect":
        # we have to specify www_root even though we always redirect/proxy
        www_root => '/var/www',

        server_name      => [$host],
        vhost_cfg_append => {
          'return' => "301 https://${host}\$request_uri",
        };
    }
  }
}
