# web display of stats
class ocf_stats::www {
  apache::vhost { 'stats.ocf.berkeley.edu':
    serveraliases => ['stats', 'stats.ocf.io', 'stats.ocf.sexy', 'stats.open.cf'],
    port          => 80,
    docroot       => '/var/www/',
    options       => ['-Indexes'],

    directories   => [{
      path        => '/var/www/',
      options     => ['+ExecCGI'],
      addhandlers => [{
        handler    => 'cgi-script',
        extensions => ['.cgi']
      }]
    }];
  }
}
