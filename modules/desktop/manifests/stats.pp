class desktop::stats {
  user {
    'ocfstats':
      comment => 'OCF Desktop Stats',
      home => '/opt/stats',
      system => true,
      groups => 'sys';
  }

  file {
    '/opt/stats':
      ensure => directory,
      owner => ocfstats,
      group => root,
      mode => 700,
      require => User['ocfstats'];
    
    '/opt/stats/.ssh':
      ensure => directory,
      owner => ocfstats,
      group => root,
      source => 'puppet:///modules/desktop/stats/ssh',
      recurse => true;
    
    '/opt/stats/update.sh':
      mode   => '500',
      owner  => ocfstats,
      source => 'puppet:///modules/desktop/stats/update.sh';

    '/opt/stats/update-delay.sh':
      mode   => '500',
      owner  => ocfstats,
      source => 'puppet:///modules/desktop/stats/update-delay.sh';

    # CA certificate (used to verify server)
    '/opt/stats/ca.crt':
      mode   => '444',
      owner  => ocfstats,
      source => 'puppet:///modules/desktop/stats/ca.crt';
    
    # local machine certificate and key
    '/opt/stats/local.key':
      mode   => '400',
      owner  => ocfstats,
      source => 'puppet:///private/stats/local.key';

    '/opt/stats/local.crt':
      mode   => '444',
      owner  => ocfstats,
      source => 'puppet:///private/stats/local.crt';

  }
}
