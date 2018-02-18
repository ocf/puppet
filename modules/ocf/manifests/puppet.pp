class ocf::puppet($stage = 'first') {
  if lookup('puppet_agent') {
    $puppet_pkg = 'puppet-agent'

    package { $puppet_pkg:; }

    augeas { '/etc/puppetlabs/puppet/puppet.conf':
      context => '/files/etc/puppetlabs/puppet/puppet.conf',
      changes => [
        # These changes can change the puppetmaster config, which is
        # defined separately in the ocf_puppet module, causing the
        # puppet agent on the puppetmaster to restart twice. Make sure
        # the changes made here are also made in that module.
        "set agent/environment ${::environment}",
        'set agent/usecacheonfailure false',
      ],
      require => Package[$puppet_pkg],
    }
  } else {
    $puppet_pkg = 'puppet'
    package { [$puppet_pkg, 'facter', 'augeas-tools', 'ruby-augeas']: }

    # Configure puppet agent
    # Set environment to match server and disable cached catalog on failure
    augeas { '/etc/puppet/puppet.conf':
      context => '/files/etc/puppet/puppet.conf',
      changes => [
        "set agent/environment ${::environment}",
        'set agent/usecacheonfailure false',
      ],
      require => Package[$puppet_pkg, 'augeas-tools'],
    }
  }

  # Run puppet as a cron job rather than as a service
  cron { 'puppet-agent':
    ensure      => present,
    command     => 'puppet-trigger',
    user        => 'root',
    minute      => [fqdn_rand(30), fqdn_rand(30) + 30],
    environment => 'PATH=/opt/puppetlabs/bin:/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin',
    require     => Package[$puppet_pkg],
  }

  service { 'puppet':
    ensure  => stopped,
    enable  => false,
    require => Package[$puppet_pkg],
  }

  # Create share directories
  file {
    '/opt/share':
      ensure => directory;

    '/opt/share/puppet':
      ensure  => directory,
      recurse => true,
      purge   => true,
      force   => true,
      backup  => false;
  }

  # Install custom scripts
  file {
    # Trigger a puppet run by the agent
    '/usr/local/sbin/puppet-trigger':
      mode    => '0755',
      source  => 'puppet:///modules/ocf/puppet-trigger';

    # TODO: Remove this entirely once all hosts have this file removed
    '/usr/local/sbin/migrate-puppet-agent':
      ensure => absent,
  }
}
