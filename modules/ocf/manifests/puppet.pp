class ocf::puppet($stage = 'first') {
  if lookup('puppet_agent') {
    package { 'puppet-agent':; }

    $cron = true

    augeas { '/etc/puppetlabs/puppet/puppet.conf':
      context => '/files/etc/puppetlabs/puppet/puppet.conf',
      changes => [
        # These changes can change the puppetmaster config, which is
        # defined separately in the ocf_puppet module, causing the
        # puppet agent on the puppetmaster to restart twice. Make sure
        # the changes made here are also made in that module.
        "set agent/environment ${::environment}",
        'set agent/usecacheonfailure false',

        # Remove a bunch of old settings that are no longer needed
        'rm main/logdir',
        'rm main/vardir',
        'rm main/ssldir',
        'rm main/rundir',
        'rm main/templatedir',
        'rm main/factpath',
        'rm main/pluginsync',
        'rm main/stringify_facts',
        'rm main/prerun_command',
        'rm main/postrun_command',
        'rm agent/certname',
        'rm master/ssl_client_header',
        'rm master/ssl_client_verify_header',
      ],
      require => Package['puppet-agent'],
    }
  } else {
    package { ['facter', 'puppet', 'augeas-tools', 'ruby-augeas']: }

    if $::lsbdistcodename == 'jessie' {
      # Puppet ships with a service, so use that instead of cron
      $cron = false

      # configure puppet agent
      # set environment to match server and disable cached catalog on failure
      augeas { '/etc/puppet/puppet.conf':
        context => '/files/etc/puppet/puppet.conf',
        changes => [
          "set agent/environment ${::environment}",
          'set agent/usecacheonfailure false',
          'set main/pluginsync true',
          'set main/stringify_facts false',
          'set main/rundir /run/puppet',

          # future parser breaks too many 3rd-party modules
          'rm main/parser',

          # templatedir is deprecated in 3.8+ and we don't use it
          'rm main/templatedir',
        ],
        require => Package['augeas-tools', 'ruby-augeas', 'puppet'],
        notify  => Service['puppet'],
      }
    } else {
      $cron = true

      augeas { '/etc/puppet/puppet.conf':
        context => '/files/etc/puppet/puppet.conf',
        changes => [
          "set agent/environment ${::environment}",
          'set agent/usecacheonfailure false',

          # Remove a bunch of old settings that are no longer needed
          'rm main/templatedir',
          'rm main/factpath',
          'rm main/pluginsync',
          'rm main/stringify_facts',
          'rm main/prerun_command',
          'rm main/postrun_command',
          'rm agent/certname',
          'rm master/ssl_client_header',
          'rm master/ssl_client_verify_header',
        ],
        require => Package['augeas-tools', 'puppet'],
      }
    }
  }

  # Run puppet as a cron job or a service, depending on the version installed.
  # Puppet 4+ doesn't ship with a service, so a cron job is used instead.
  if $cron {
    cron { 'puppet-agent':
      ensure      => present,
      command     => 'puppet agent --verbose --onetime --no-daemonize --logdest syslog > /dev/null 2>&1',
      user        => 'root',
      minute      => [fqdn_rand(30), fqdn_rand(30) + 30],
      environment => 'PATH=/opt/puppetlabs/bin:/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin'
    }

    service { 'puppet':
      ensure  => stopped,
      enable  => false,
      require => Package['puppet'],
    }
  } else {
    service { 'puppet':
      require => Package['puppet'],
    }
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
  }
}
