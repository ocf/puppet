class ocf_stats::labstats {
  include ocf::firewall::output_printers

  user {
    'ocfstats':
      comment => 'OCF Lab Stats',
      home    => '/opt/stats',
      system  => true,
      groups  => 'sys';
  }

  $file_defaults = {
    owner => ocfstats,
    group => ocfstats,
  }
  file {
    '/opt/stats':
      ensure => directory,
      *      => $file_defaults;

    '/opt/stats/ocfstats-password':
      content => hiera('ocfstats::mysql::password'),
      mode    => '0600',
      require => File['/opt/stats'],
      *       => $file_defaults;

    '/opt/stats/bin':
      ensure  => directory,
      source  => 'puppet:///modules/ocf_stats/stats/bin',
      mode    => '0755',
      recurse => true,
      require => File['/opt/stats/ocfstats-password'],
      *       => $file_defaults;
  }

  $cron_defaults = {
    user        => 'ocfstats',
    environment => 'MAILTO=root',
    require     => File['/opt/stats/bin'],
  }
  cron {
    'close-old-sessions':
      command => '/opt/stats/bin/close-old-sessions',
      minute  => '*',
      *       => $cron_defaults;

    'update-groups':
      command => '/opt/stats/bin/update-groups',
      minute  => '*/15',
      *       => $cron_defaults;

    'update-printer-stats':
      command => '/opt/stats/bin/update-printer-stats',
      minute  => '*/5',
      *       => $cron_defaults;

    'low-toner-alert':
      command => '/opt/stats/bin/low-toner-alert',
      minute  => '*/15',
      *       => $cron_defaults;
  }
}
