class ocf_puppet {
  include ocf::packages::ldapvi

  include puppetmaster

  file { '/etc/sudoers.d/ocfdeploy-puppet':
    content => "ocfdeploy ALL=NOPASSWD: /opt/puppet/scripts/update-prod\n",
    owner   => root,
    group   => root;
  }
}
