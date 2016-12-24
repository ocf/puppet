class ocf_puppet {
  include ocf::packages::ldapvi

  include ocf_puppet::environments
  include ocf_puppet::puppetmaster

  file { '/etc/sudoers.d/ocfdeploy-puppet':
    content => "ocfdeploy ALL=NOPASSWD: /opt/puppetlabs/scripts/update-prod\n";
  }
}
