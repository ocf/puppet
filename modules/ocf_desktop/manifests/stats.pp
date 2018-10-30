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
      
    '/opt/stats/update-flags.sh':
      mode   => '0555',
      owner  => ocfstats,
      source => 'puppet:///modules/ocf_desktop/stats/update-flags.sh';
  }

  cron { 'labstats':
    ensure  => present,
    command => '/opt/stats/update.sh > /dev/null',
    user    => 'ocfstats',
    minute  => '*';
  }
}
