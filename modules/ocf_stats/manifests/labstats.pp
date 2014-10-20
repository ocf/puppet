class ocf_stats::labstats {
  package {
    ['mysql-server', 'python-pysnmp4']:;
  }

  user {
    'ocfstats':
      comment => 'OCF Lab Stats',
      home    => '/opt/stats',
      system  => true,
      groups  => 'sys';
  }

  File {
    owner => ocfstats,
    group => ocfstaff
  }

  file {
    ['/opt/stats', '/opt/stats/printing', '/opt/stats/printing/history',
    '/opt/stats/printing/oracle']:
        ensure => directory,
        mode   => '0755';
      '/opt/stats/desktop_list':
        mode   => '0444',
        source => 'puppet:///contrib/desktop/desktop_list';
  }

  vcsrepo { '/opt/stats/labstats':
    ensure   => latest,
    provider => git,
    revision => 'master',
    source   => 'https://github.com/ocf/labstats.git';
  }

  cron {
    'labstats':
      ensure      => present,
      command     => '/opt/stats/lab-cron.sh > /dev/null',
      environment => 'MAILTO=root',
      user        => 'ocfstats',
      weekday     => '*',
      month       => '*',
      monthday    => '*',
      hour        => '*',
      minute      => '*';

    'printstats':
      ensure      => present,
      command     => '/opt/stats/print-cron.sh > /dev/null',
      environment => 'MAILTO=root',
      user        => 'ocfstats',
      weekday     => '*',
      month       => '*',
      monthday    => '*',
      hour        => '*',
      minute      => '*/5';
  }
}
