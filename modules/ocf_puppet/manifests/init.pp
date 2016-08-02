class ocf_puppet {
  include ocf::packages::ldapvi

  include environments
  include puppetmaster
  include report

  file { '/etc/sudoers.d/ocfdeploy-puppet':
    content => "ocfdeploy ALL=NOPASSWD: /opt/puppet/scripts/update-prod\n";
  }
}
