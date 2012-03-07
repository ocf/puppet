class ocf::local::lightning {

  # this is the puppet master
  package { 'puppet':
    name    => [ 'puppet', 'puppetmaster', 'puppetmaster-passenger' ]
  }
  file { '/etc/default/puppetmaster':
    source  => 'puppet:///modules/ocf/local/lightning/puppetmaster',
    require => Package['puppet']
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

}
