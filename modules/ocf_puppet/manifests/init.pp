class ocf_puppet {
  include ocf_ssl::default_bundle
  include ocf_puppet::environments
  include ocf_puppet::puppetboard
  include ocf_puppet::puppetmaster

  file { '/etc/sudoers.d/ocfdeploy-puppet':
    content => "ocfdeploy ALL=NOPASSWD: /opt/puppetlabs/scripts/update-prod\n";
  }

  # Staff need to use virtualenv to run tests.
  package { 'virtualenv': }
}
