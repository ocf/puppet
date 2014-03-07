class dementors::labstats {
  package {
    ['mysql-server', 'pssh']:;
  }

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
      group => ocfstaff,
      mode => 775,
      require => User['ocfstats'];
    '/opt/stats/cgi':
      ensure => directory,
      owner => ocfstats,
      group => ocfstaff,
      mode => 775;
    '/opt/stats/desktop_list':
      owner => ocfstats,
      group => ocfstaff,
      mode => 444,
      source => 'puppet:///contrib/desktop/desktop_list';
    '/opt/stats/id_rsa':
      owner => ocfstats,
      group => root,
      mode => 400,
      source => 'puppet:///private/stats/id_rsa';
    '/opt/stats/id_rsa.pub':
      owner => ocfstats,
      group => ocfstaff,
      mode => 444,
      source => 'puppet:///modules/dementors/stats/id_rsa.pub';
  }
  
  cron { "labstats":
    ensure => present,
    command => "/opt/stats/lab-cron.sh > /dev/null",
    user => "ocfstats",
    weekday => "*",
    month => "*",
    monthday => "*",
    hour => "*",
    minute => "*";
  }
}
