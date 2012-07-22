class ocf::local::lightning {

  # this is the puppet master
  package { [ 'puppetmaster', 'puppetmaster-passenger' ]:
    ensure  => latest,
    require => Exec['puppetlabs']
  }
  # puppet manifest help
  package { [ 'puppet-lint', 'vim-puppet' ]: }
  file {
    # disable WEBrick, use Puppet through Passenger in Apache
    '/etc/default/puppetmaster':
      source  => 'puppet:///modules/ocf/local/lightning/puppetmaster',
      require => Package[ 'puppetmaster', 'puppetmaster-passenger' ];
    # Apache: only listen on private interface and ports used by Puppet
    '/etc/apache2/ports.conf':
      content => '# only listen on private interface and ports used by Puppet';
    # Apache: enable only Puppet Passenger vhost
    '/etc/apache2/sites-enabled':
      ensure  => directory,
      recurse => true,
      purge   => true,
      force   => true,
      source  => 'puppet:///modules/ocf/local/lightning/sites-enabled';
  }

  # remove conflicting logrotate rule already defined in /etc/logrotate.d/puppet
  file { '/etc/logrotate.d/puppetmaster':
    ensure => absent
  }

  # remote package management
  package { 'apt-dater': }
  file { '/root/apt-dater.keytab':
    mode   => '0600',
    backup => false,
    source => 'puppet:///private/apt-dater.keytab'
  }

  # send magic packet to wakeup desktops at lab opening time
  package { 'wakeonlan': }
  file {
    '/usr/local/bin/ocf-wakeup':
      mode    => '0755',
      source  => 'puppet:///modules/ocf/local/lightning/ocf-wakeup',
      require => Package['wakeonlan'];
    '/etc/cron.d/ocf-wakeup':
      source  => 'puppet:///modules/ocf/local/lightning/crontab',
      require => File['/usr/local/bin/ocf-wakeup']
  }

  # provide miscellaneous puppet directories
  file {
    '/opt/puppet':
      ensure  => directory;
    # provide alternate environments
    '/opt/puppet/env':
      ensure  => directory;
    # provide default production environment
    '/opt/puppet/env/production':
      ensure  => symlink,
      target  => '/etc/puppet';
    # provide scripts directory
    '/opt/puppet/scripts':
      ensure  => directory,
      mode    => '0755',
      recurse => true,
      purge   => true,
      force   => true,
      source  => 'puppet:///modules/ocf/local/lightning/puppet-scripts';
    # provide public external content
    '/opt/puppet/contrib':
      ensure  => directory;
    # provide private per-host shares
    '/opt/puppet/private':
      ensure  => directory,
      mode    => '0400',
      owner   => 'puppet',
      group   => 'puppet',
      recurse => true
  }

}
