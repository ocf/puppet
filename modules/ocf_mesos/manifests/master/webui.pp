class ocf_mesos::master::webui(
    $mesos_fqdn,
    $marathon_fqdn,
) {
  require ocf_ssl

  class { 'nginx':
    # if we let nginx manage its own repo, it uses the `apt` module; this
    # creates an unresolvable dependency cycle because we declare class `apt`
    # in stage first (and we're currently in stage main)
    manage_repo => false;
  }

  nginx::resource::upstream {
    'mesos':
      members => ['localhost:5050'];

    'marathon':
      members => ['localhost:8080'];
  }

  Nginx::Resource::Vhost {

    ssl_cert    => "/etc/ssl/private/${::fqdn}.bundle",
    ssl_key     => "/etc/ssl/private/${::fqdn}.key",
    ssl_dhparam => '/etc/ssl/dhparam.pem',
    add_header  => {
      'Strict-Transport-Security' => 'max-age=31536000',
    },

    proxy_set_header => [
      'X-Forwarded-Protocol $scheme',
      'X-Forwarded-For $proxy_add_x_forwarded_for',
      'Host $http_host'
    ],
  }

  nginx::resource::vhost {
    # mesos
    'mesos':
      server_name    => [$mesos_fqdn],
      proxy          => 'http://mesos',
      ssl            => true,
      listen_port    => 443,

      # Mesos will redirect to a URL like "//mesos5:5050" when redirecting to
      # the current leader; we want to remove the port and go to the HTTPS site
      # with the entire FQDN instead.
      proxy_redirect => '~^//mesos([0-9]+):5050$ https://mesos$1.ocf.berkeley.edu/';

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
      listen_port => 443;

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
