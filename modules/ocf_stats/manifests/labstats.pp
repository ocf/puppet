class ocf_stats::labstats {
  package {
    ['mysql-client', 'python-pysnmp4']:;
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
    group => ocfstats
  }

  file {
    ['/opt/stats', '/opt/stats/var', '/opt/stats/var/printing',
    '/opt/stats/var/printing/history', '/opt/stats/var/printing/oracle']:
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

  file { '/opt/stats/labstats/labstats/settings.py':
    source  => 'puppet:///private/stats/settings.py',
    owner   => ocfstats,
    group   => www-data,
    mode    => '0640',
    require => Vcsrepo['/opt/stats/labstats'];
  }

  apache::vhost { 'stats.ocf.berkeley.edu-control':
    servername => 'stats.ocf.berkeley.edu',
    port       => 444,
    docroot    => '/opt/stats/labstats/cgi/',
    options    => ['-Indexes'],

    ssl => true,
    ssl_cert => '/etc/ssl/private/stats.crt',
    ssl_key  => '/etc/ssl/private/stats.key',
    ssl_ca   => '/etc/ssl/stats/ca/ca.crt',

    ssl_verify_client => 'require',
    ssl_verify_depth  => 1,

    # pass SSL_CLIENT_* vars to CGI
    ssl_options => '+StdEnvVars',

    directories   => [{
      path        => '/opt/stats/labstats/cgi/',
      options     => ['+ExecCGI'],

      addhandlers => [{
        handler    => 'cgi-script',
        extensions => ['.cgi']
      }]
    }];
  }

  cron {
    'labstats':
      command     => '/opt/stats/labstats/cron/lab-cron > /dev/null',
      environment => 'MAILTO=root',
      user        => 'ocfstats',
      minute      => '*';

    'printstats':
      command     => '/opt/stats/labstats/cron/print-cron > /dev/null',
      environment => 'MAILTO=root',
      user        => 'ocfstats',
      minute      => '*/5';

    'toner':
      command     => '/opt/stats/labstats/printing/toner 2> /dev/null',
      environment => 'MAILTO=root',
      user        => 'ocfstats',
      minute      => '*/5';
  }
}
