# web display of stats
class ocf_stats::www {
  apache::vhost { 'stats.ocf.berkeley.edu':
    serveraliases => ['stats'],
    port          => 80,
    docroot       => '/opt/stats/labstats/www/',
    options       => ['-Indexes'],

    directories   => [{
      path        => '/opt/stats/labstats/www/',
      options     => ['+ExecCGI'],
      addhandlers => [{
        handler    => 'cgi-script',
        extensions => ['.cgi']
      }]
    }];
  }
}
