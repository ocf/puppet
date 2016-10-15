class ocf_mesos::master::webui(
    $mesos_fqdn,
    $mesos_http_password,
    $marathon_fqdn,
    $marathon_http_password,
) {
  require ocf_ssl

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

  class { 'nginx':
    # We need the PAM authentication module.
    package_name => 'nginx-extras',

    manage_repo  => false,
    confd_purge  => true,
    vhost_purge  => true,
  }

  nginx::resource::upstream {
    'mesos':
      members => ['localhost:5050'];

    'marathon':
      members => ['localhost:8080'];
  }

  $mesos_auth_header = base64('encode', "ocf:${mesos_http_password}", 'strict')
  $marathon_auth_header = base64('encode', "marathon:${marathon_http_password}", 'strict')

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

    'mesos-https-redirect':
      # we have to specify www_root even though we always redirect/proxy
      www_root => '/var/www',

      server_name      => [$::hostname, $::fqdn, 'mesos', 'mesos.ocf.berkeley.edu'],
      ssl              => true,
      listen_port      => 443,
      vhost_cfg_append => {
        'return' => "301 https://${mesos_fqdn}/master/redirect",
      };

    'mesos-http-redirect':
      # we have to specify www_root even though we always redirect/proxy
      www_root => '/var/www',

      server_name      => [$::hostname, $::fqdn, 'mesos', 'mesos.ocf.berkeley.edu'],
      vhost_cfg_append => {
        'return' => "301 https://${mesos_fqdn}/master/redirect",
      };

    # marathon
    'marathon':
      server_name => [$marathon_fqdn],
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

    'marathon-https-redirect':
      # we have to specify www_root even though we always redirect/proxy
      www_root => '/var/www',

      server_name      => ['marathon', 'marathon.ocf.berkeley.edu'],
      ssl              => true,
      listen_port      => 443,
      vhost_cfg_append => {
        'return' => "301 https://${marathon_fqdn}\$request_uri",
      };

    'marathon-http-redirect':
      # we have to specify www_root even though we always redirect/proxy
      www_root => '/var/www',

      server_name      => ['marathon', 'marathon.ocf.berkeley.edu'],
      vhost_cfg_append => {
        'return' => "301 https://${marathon_fqdn}\$request_uri",
      };
  }
}
