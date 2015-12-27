class ocf_stats::labstats {
  include ocf::packages::matplotlib

  package { ['python3-mysql.connector', 'imagemagick', 'inkscape']:; }

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
  }

  vcsrepo { '/opt/stats/labstats':
    ensure   => latest,
    provider => git,
    revision => 'master',
    source   => 'https://github.com/ocf/labstats.git';
  }

  file { '/opt/stats/labstats/labstats/settings.py':
    source  => 'puppet:///private/stats/settings.py',
    group   => www-data,
    mode    => '0640',
    require => Vcsrepo['/opt/stats/labstats'];
  }

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
  }
}
