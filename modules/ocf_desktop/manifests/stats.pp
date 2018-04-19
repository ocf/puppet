class ocf_desktop::stats {
  user {
    'ocfstats':
      comment => 'OCF Desktop Stats',
      home    => '/opt/stats',
      system  => true,
      groups  => 'sys';
  }

  file {
    '/opt/stats':
      ensure  => directory,
      owner   => ocfstats,
      group   => root,
      mode    => '0755',
      require => User['ocfstats'];

    '/opt/stats/update.sh':
      mode   => '0555',
      owner  => ocfstats,
      source => 'puppet:///modules/ocf_desktop/stats/update.sh';

    '/opt/stats/update-delay.sh':
      mode   => '0555',
      owner  => ocfstats,
      source => 'puppet:///modules/ocf_desktop/stats/update-delay.sh';
  }

  cron { 'labstats':
    ensure      => present,
    environment => 'PATH=/usr/local/sbin:/usr/local/bin:/bin:/usr/sbin:/usr/bin:/opt/puppetlabs/bin',
    command     => '/opt/stats/update.sh > /dev/null',
    user        => 'ocfstats',
    minute      => '*';
  }
}
