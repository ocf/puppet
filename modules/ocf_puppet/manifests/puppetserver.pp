class ocf_puppet::puppetserver {
  package {
    ['puppetserver', 'puppet-lint', 'augeas-tools']:;
  }

  # This defines Service['puppetserver'], so we can't do it ourselves.
  class { 'puppetdb::master::config':
    puppetdb_server             => 'puppetdb',

    # Prevent hard Puppet failures if PuppetDB is not available
    puppetdb_soft_write_failure => true,
  }

  # Set correct memory limits on puppetserver so that it doesn't run out
  augeas { '/etc/default/puppetserver':
    context => '/files/etc/default/puppetserver',
    changes => [
      "set JAVA_ARGS '\"-Xms1536m -Xmx1536m\"'",
    ],
    require => Package['puppetserver'],
    notify  => Service['puppetserver'],
  }

  $docker_private_hosts = union(
    keys(lookup('mesos_masters')),
    lookup('mesos_slaves'),
    lookup('kubernetes::worker_nodes'),
  )

  # Allow Mesos agents and masters to access docker secrets
  puppet_authorization::rule { 'private-docker':
    match_request_path   => '^/puppet/v3/file_(content|metadata)s?/private-docker$',
    match_request_type   => 'regex',
    match_request_method => ['get', 'post'],
    allow                => suffix($docker_private_hosts, '.ocf.berkeley.edu'),
    sort_order           => 500,
    path                 => '/etc/puppetlabs/puppetserver/conf.d/auth.conf',
    require              => Package['puppetserver'],
    notify               => Service['puppetserver'],
  }

  # Allow kubernetes masters to access kubernetes secrets
  puppet_authorization::rule { 'kubernetes-secrets':
    match_request_path   => '^/puppet/v3/file_(content|metadata)s?/kubernetes-secrets$',
    match_request_type   => 'regex',
    match_request_method => ['get'],
    allow                => suffix(lookup('kubernetes::master_nodes'), '.ocf.berkeley.edu'),
    sort_order           => 500,
    path                 => '/etc/puppetlabs/puppetserver/conf.d/auth.conf',
    require              => Package['puppetserver'],
    notify               => Service['puppetserver'],
  }

  # allow the puppetmaster itself to get/set all certificate information
  puppet_authorization::rule { 'allow-puppetserver-cli':
    match_request_path   => '/puppet-ca/v1/(?:certificate|certificate_status)',
    match_request_type   => 'regex',
    match_request_method => ['get', 'post', 'put', 'delete'],
    allow                => $::fqdn,
    sort_order           => 998,
    path                 => '/etc/puppetlabs/puppetserver/conf.d/auth.conf',
    require              => Package['puppetserver'],
    notify               => Service['puppetserver'],
  }

  # let anyone get the ocfweb certs
  puppet_authorization::rule { 'ocfweb-cert':
    match_request_path   => '^/puppet/v3/file_(content|metadata)s?/private-docker/ocfweb/puppet-certs$',
    match_request_type   => 'regex',
    match_request_method => ['get', 'post'],
    allow                => '*.ocf.berkeley.edu',
    sort_order           => 500,
    path                 => '/etc/puppetlabs/puppetserver/conf.d/auth.conf',
    require              => Package['puppetserver'],
    notify               => Service['puppetserver'],
  }

  file {
    '/etc/puppetlabs/puppet/fileserver.conf':
      source  => 'puppet:///modules/ocf_puppet/fileserver.conf',
      require => Package['puppetserver'],
      notify  => Service['puppetserver'];

    '/etc/puppetlabs/puppet/tagmail.conf':
      source  => 'puppet:///modules/ocf_puppet/tagmail.conf',
      require => Package['puppetserver'],
      notify  => Service['puppetserver'];

    '/etc/puppetlabs/puppetserver/conf.d/webserver.conf':
      content => template('ocf_puppet/webserver.conf.erb'),
      require => Package['puppetserver'],
      notify  => Service['puppetserver'];

    '/opt/share/puppet/ldap-enc':
      mode    => '0755',
      source  => 'puppet:///modules/ocf_puppet/ldap-enc',
      require => File['/opt/share/puppet'];

    '/etc/puppetlabs/puppet/puppet.conf':
      content => template('ocf_puppet/puppet.conf.erb'),
      require => Package['puppet-agent'];

    ['/opt/puppet', '/opt/puppetlabs/scripts', '/opt/puppetlabs/shares']:
      ensure  => directory,
      require => Package['puppetserver'];

    '/opt/puppetlabs/shares/private':
      mode    => '0400',
      owner   => puppet,
      group   => puppet,
      recurse => true,
      require => File['/opt/puppetlabs/shares'];

    '/opt/puppetlabs/scripts/update-prod':
      source => 'puppet:///modules/ocf_puppet/update-prod',
      mode   => '0755';

    # These are just links to the new locations, but keep them for staff to use
    # since they are much more convenient to type.
    '/opt/puppet/env':
      ensure  => symlink,
      target  => '/etc/puppetlabs/code/environments',
      require => Package['puppetserver'];

    '/opt/puppet/shares':
      ensure  => symlink,
      target  => '/opt/puppetlabs/shares',
      require => Package['puppetserver'];
  }

  vcsrepo { '/opt/puppetlabs/shares/etc':
    ensure   => latest,
    provider => git,
    revision => 'master',
    source   => 'https://github.com/ocf/etc.git',
    owner    => puppet,
    group    => puppet,
    require  => File['/opt/puppetlabs/shares'];
  }
}
