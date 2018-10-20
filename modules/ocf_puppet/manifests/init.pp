class ocf_puppet {
  include ocf::ssl::default
  include ocf_puppet::environments
  include ocf_puppet::firewall_input
  include ocf_puppet::puppetboard
  include ocf_puppet::puppetserver

  file { '/etc/sudoers.d/ocfdeploy-puppet':
    content => "ocfdeploy ALL=NOPASSWD: /opt/puppetlabs/scripts/update-prod\n";
  }

  package {
    # Keychain is useful for managing SSH and GPG agents
    'keychain':;

    # Staff need to use virtualenv to run tests.
    'virtualenv':;
  }
}
