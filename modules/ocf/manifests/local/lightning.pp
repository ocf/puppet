class ocf::local::lightning {

  # this is the puppet master
  package { [ 'puppet', 'puppetmaster', 'puppetmaster-passenger' ]: }
  file { '/etc/default/puppetmaster':
    source  => 'puppet:///modules/ocf/local/lightning/puppetmaster',
    require => Package[ 'puppetmaster', 'puppetmaster-passenger' ]
  }

  # send magic packet to wakeup desktops at lab opening time
  package { 'wakeonlan': }
  file {
    '/usr/local/sbin/ocf-wakeup':
      mode    => 0755,
      source  => 'puppet:///modules/ocf/local/lightning/ocf-wakeup',
      require => Package['wakeonlan'];
    '/etc/cron.d/ocf-wakeup':
      source  => 'puppet:///modules/ocf/local/lightning/crontab',
      require => File['/usr/local/sbin/ocf-wakeup']
  }

  # provide miscellaneous puppet directories
  file {
    '/opt/puppet':
      ensure  => directory;
    # provide alternate environments
    '/opt/puppet/env':
      ensure  => directory;
    # provide scripts directory
    '/opt/puppet/scripts':
      ensure  => directory,
      mode    => 0755,
      recurse => true,
      purge   => true,
      source  => 'puppet:///modules/ocf/local/lightning/puppet-scripts';
    # provide public external content
    '/opt/puppet/contrib':
      ensure  => directory;
    # provide private per-host shares
    '/opt/puppet/private':
      ensure  => directory,
      mode    => 0400,
      owner   => 'puppet',
      group   => 'puppet',
      recurse => true
  }

}
