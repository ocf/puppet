class ocf_puppet::puppetmaster {
  package {
    ['puppetserver', 'puppet-lint']:;
  }

  service { 'puppetserver':
    enable  => true,
    require => Package['puppetserver'],
  }

  # Set correct memory limits on puppetserver so that it doesn't run out
  augeas { '/etc/default/puppetserver':
    context => '/files/etc/default/puppetserver',
    changes => [
      "set JAVA_ARGS '\"-Xms512m -Xmx512m -XX:MaxPermSize=256m\"'",
    ],
    require => Package['puppetserver'],
    notify  => Service['puppetserver'],
  }

  $docker_private_hosts = union(keys(hiera('mesos_masters')), hiera('mesos_slaves'))

  file {
    '/etc/puppetlabs/puppet/fileserver.conf':
      content => template('ocf_puppet/fileserver.conf.erb'),
      require => Package['puppetserver'],
      notify  => Service['puppetserver'];

    '/etc/puppetlabs/puppet/tagmail.conf':
      source  => 'puppet:///modules/ocf_puppet/tagmail.conf',
      require => Package['puppetserver'],
      notify  => Service['puppetserver'];

    '/opt/share/puppet/ldap-enc':
      mode    => '0755',
      source  => 'puppet:///modules/ocf_puppet/ldap-enc',
      require => File['/opt/share/puppet'];

    '/etc/puppetlabs/puppet/puppet.conf':
      content => template('ocf_puppet/puppet.conf.erb'),
      require => Package['puppet-agent'];

    ['/opt/puppetlabs/scripts', '/opt/puppetlabs/shares', '/opt/puppetlabs/shares/contrib']:
      ensure  => directory,
      require => Package['puppetserver'];

    '/opt/puppetlabs/shares/private':
      mode    => '0400',
      owner   => puppet,
      group   => puppet,
      recurse => true,
      require => File['/opt/puppetlabs/shares'];

    '/opt/puppetlabs/scripts/update-prod':
      source  => 'puppet:///modules/ocf_puppet/update-prod',
      mode    => '0755';

    # TODO: Remove old puppet directories after the upgrade is fully done
    # (for now they are just links to the new locations)
    '/opt/puppet/env':
      ensure  => symlink,
      target  => '/etc/puppetlabs/code/environments',
      require => Package['puppetserver'];

    '/opt/puppet/shares':
      ensure  => symlink,
      target  => '/opt/puppetlabs/shares',
      require => Package['puppetserver'];
  }
}
