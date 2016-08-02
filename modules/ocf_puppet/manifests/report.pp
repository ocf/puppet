class ocf_puppet::report {

  # Reports via IRC

  # TODO

  # Standard email reports

  file { '/usr/local/bin/puppet-report':
    source  => 'puppet:///modules/ocf_puppet/puppet-report',
    mode    => '0755',
  }

  cron { 'puppet-report-desktop':
    command => '/usr/local/bin/puppet-report --digest desktop',
    user    => puppet,
    minute  => [0, 30],
    require => File['/usr/local/bin/puppet-report'],
  }

  cron { 'puppet-report-server':
    command => '/usr/local/bin/puppet-report server',
    user    => puppet,
    minute  => [15, 45],
    require => File['/usr/local/bin/puppet-report'],
  }
}
