# grafana config
class ocf_stats::grafana {
  class { 'ocf::packages::grafana::apt':
    stage => first,
  }

  $canonical_url = $::host_env ? {
    'dev'  => 'dev-prometheus',
    'prod' => 'prometheus',
  }

  class { 'grafana':
    install_method           => 'repo',

    # Unfortunately, puppet-grafana requires that we specify a version number
    # here.
    version                  => '5.2.1',
    manage_package_repo      => false,

    cfg                      => {
      app_mode         => 'production',
      server           => {
        http_addr => '127.0.0.1',
        http_port => 8990,
        domain    => "${canonical_url}.ocf.berkeley.edu",
        root_url  => "https://${canonical_url}.ocf.berkeley.edu/grafana/",
      },
      database         => {
        type => 'sqlite3',
        path => 'grafana.db',
      },
      users            => {
        auto_assign_org      => true,
        allow_sign_up        => false,
        auto_assign_org_role => 'Editor',
      },
      'auth.anonymous' => {
        enabled  => true,
      },
      security         => {
        disable_gravatar => true,
      },
    },

    provisioning_datasources => {
      apiVersion  => 1,
      datasources => [
        {
          name      => 'Prometheus',
          type      => 'prometheus',
          access    => 'direct',
          url       => 'https://prometheus.ocf.berkeley.edu/',
          isDefault => true,
        },
      ],
    },

    # TODO: it's possible to save dashboards in Puppet with
    # provisioning_dashboards. Once we settle on dashboards, we should put them
    # here so they can be saved in VCS.
  }
}
