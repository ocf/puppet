class ocf_stats::labstats {
  user {
    'ocfstats':
      comment => 'OCF Lab Stats',
      home    => '/opt/stats',
      system  => true,
      groups  => 'sys';
  }

  # TODO: Remove these two, the labstats repo only needs to have the desktop
  # update endpoint and maybe the web interface moved to ocfweb (if we want a
  # graph of toner levels, that is)
  vcsrepo { '/opt/stats/labstats':
    ensure   => latest,
    provider => git,
    revision => 'master',
    source   => 'https://github.com/ocf/labstats.git';
  }

  file { '/opt/stats/labstats/labstats/settings.py':
    source  => 'puppet:///private/stats/settings.py',
    owner   => ocfstats,
    group   => www-data,
    mode    => '0640',
    require => Vcsrepo['/opt/stats/labstats'];
  }

  # TODO: Remove this by moving the endpoint for desktop session updates to
  # ocfweb API (rt#6624)
  apache::vhost { 'labstats.ocf.berkeley.edu':
    servername => 'labstats.ocf.berkeley.edu',
    port       => 444,
    docroot    => '/opt/stats/labstats/cgi/',
    options    => ['-Indexes'],

    ssl        => true,
    ssl_key    => "/etc/ssl/private/${::fqdn}.key",
    ssl_cert   => "/etc/ssl/private/${::fqdn}.crt",
    ssl_chain  => '/etc/ssl/certs/incommon-intermediate.crt',

    directories   => [{
      path        => '/opt/stats/labstats/cgi/',
      options     => ['+ExecCGI'],

      addhandlers => [{
        handler    => 'cgi-script',
        extensions => ['.cgi']
      }]
    }];
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
