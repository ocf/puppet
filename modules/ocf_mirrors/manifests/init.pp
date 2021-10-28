class ocf_mirrors {
  require ocf::ssl::default
  require ocf::packages::rsync

  include ocf_mirrors::ftp
  include ocf_mirrors::rsync
  include ocf_mirrors::firewall_input

  # projects
  include ocf_mirrors::projects::apache
  include ocf_mirrors::projects::alpine
  include ocf_mirrors::projects::archlinux
  include ocf_mirrors::projects::archlinuxcn
  include ocf_mirrors::projects::centos
  include ocf_mirrors::projects::centos_altarch
  include ocf_mirrors::projects::centos_debuginfo
  include ocf_mirrors::projects::debian
  include ocf_mirrors::projects::devuan
  include ocf_mirrors::projects::emacs_lisp_archive
  include ocf_mirrors::projects::fedora
  include ocf_mirrors::projects::finnix
  include ocf_mirrors::projects::freebsd
  include ocf_mirrors::projects::gnu
  include ocf_mirrors::projects::kali
  include ocf_mirrors::projects::kde
  include ocf_mirrors::projects::kde_applicationdata
  include ocf_mirrors::projects::manjaro
  include ocf_mirrors::projects::openbsd
  include ocf_mirrors::projects::parrot
  include ocf_mirrors::projects::puppetlabs
  include ocf_mirrors::projects::qt
  include ocf_mirrors::projects::raspbian
  include ocf_mirrors::projects::tails
  include ocf_mirrors::projects::trisquel
  include ocf_mirrors::projects::ubuntu
  package {
      [
        'prometheus-apache-exporter',
      ]:;
    }
  # Prometheus user needed for the prometheus-apache-exporter daemon,
  # which runs as user "prometheus"
  user {
    'prometheus':
      comment  => 'prometheus user for running exporters',

      # Set to have no password, only allow key-based login
      password => '*',
  }
  user { 'mirrors':
    comment  => 'OCF Mirroring',
    home     => '/opt/mirrors',
    shell    => '/bin/bash',

    # Set to have no password, only allow key-based login
    password => '*',
  }

  $ocfstats_password = lookup('ocfstats::mysql::password')

  file {
    ['/opt/mirrors', '/opt/mirrors/ftp', '/opt/mirrors/project', '/opt/mirrors/bin']:
      ensure  => directory,
      mode    => '0755',
      owner   => mirrors,
      group   => mirrors,
      require => User['mirrors'];

    '/opt/mirrors/ftp/README.html':
      source => 'puppet:///modules/ocf_mirrors/README.html',
      owner  => mirrors,
      group  => mirrors;

    '/opt/mirrors/ftp/robots.txt':
      source => 'puppet:///modules/ocf_mirrors/robots.txt',
      owner  => mirrors,
      group  => mirrors;

    '/var/log/rsync':
      ensure => directory;
  }

  class {
    '::apache':
      keepalive   => 'on',
      log_formats => {
        # A custom log format that counts bytes transferred by accesses (mod_logio)
        io_count => '%h %l %u %t \"%r\" %>s %b \"%{Referer}i\" \"%{User-Agent}i\" %I %O',
      },
      # "false" lets us define the class below with custom args
      mpm_module  => false;

    '::apache::mod::worker':
      startservers    => 8,
      # maxclients should be set to a max of serverlimit * threadsperchild
      maxclients      => 5000,
      threadsperchild => 50,
      serverlimit     => 100;
  }
  include apache::mod::headers
  include apache::mod::status
  include apache::mod::rewrite

  # Restart apache if any cert changes occur
  Class['ocf::ssl::default'] ~> Class['Apache::Service']

  # The Apache project requires very particular configuration:
  # https://www.apache.org/info/how-to-mirror.html#Configuration
  $apache_project_directory_options = {
    path          => '/opt/mirrors/ftp/apache',
    options       => ['Indexes', 'SymLinksIfOwnerMatch', 'FollowSymLinks'],
    index_options => [
      'FancyIndexing',
      'NameWidth=*',
      'FoldersFirst',
      'ScanHTMLTitles',
      'DescriptionWidth=*'
    ],
    allow_override => ['FileInfo', 'Indexes'],
    error_documents => [
      {
        error_code => '404',
        document => 'default',
      }
    ],
    custom_fragment => "
      HeaderName HEADER.html
      ReadmeName README.html
    ",
  }

  apache::vhost { 'mirrors.ocf.berkeley.edu':
    serveraliases     => ['mirrors', 'dl.amnesia.boum.org', '*.dl.amnesia.boum.org'],
    port              => 80,
    default_vhost     => true,
    docroot           => '/opt/mirrors/ftp',

    directories       => [
      {
        path            => '/opt/mirrors/ftp',
        options         => ['+Indexes', '+SymlinksIfOwnerMatch'],
        custom_fragment => '
          RewriteEngine On
          RewriteCond "%{HTTP_USER_AGENT}" "MSIE 7\.0|Chrome\/49\.0|Chrome\/67\.0|Edg\/85\.0\.537\.0"
          RewriteRule ^ - [F]
        ',
        index_options   => ['NameWidth=*', '+SuppressDescription']
      },
      $apache_project_directory_options,
    ],

    access_log_format => 'io_count',
    custom_fragment   => "
      Protocols h2c http/1.1
      HeaderName README.html
      ReadmeName FOOTER.html
    ",
  }

  apache::vhost { 'mirrors.berkeley.edu':
    port            => 80,

    # we have to specify docroot even though we always redirect
    docroot         => '/var/www',
    custom_fragment => 'Protocols h2c http/1.1',
    redirect_source => '/',
    redirect_dest   => 'http://mirrors.ocf.berkeley.edu/',
    redirect_status => '301',
  }

  apache::vhost { 'mirrors.ocf.berkeley.edu-ssl':
    servername        => 'mirrors.ocf.berkeley.edu',
    port              => 443,
    docroot           => '/opt/mirrors/ftp',

    directories       => [
      {
        path            => '/opt/mirrors/ftp',
        options         => ['+Indexes', '+SymlinksIfOwnerMatch'],
        custom_fragment => '
          RewriteEngine On
          RewriteCond "%{HTTP_USER_AGENT}" "MSIE 7\.0|Chrome\/49\.0|Chrome\/67\.0|Edg\/85\.0\.537\.0"
          RewriteRule ^ - [F]
        ',
        index_options   => ['NameWidth=*', '+SuppressDescription']
      },
      $apache_project_directory_options,
    ],

    access_log_format => 'io_count',
    custom_fragment   => "
      Protocols h2 http/1.1
      HeaderName README.html
      ReadmeName FOOTER.html
    ",

    ssl               => true,
    ssl_key           => "/etc/ssl/private/${::fqdn}.key",
    ssl_cert          => "/etc/ssl/private/${::fqdn}.crt",
    ssl_chain         => "/etc/ssl/private/${::fqdn}.intermediate",
  }

  file { '/opt/mirrors/bin/report-sizes':
    source => 'puppet:///modules/ocf_mirrors/report-sizes',
    mode   => '0755',
  } ->
  cron { 'report-sizes':
    command => '/opt/mirrors/bin/report-sizes',
    special => 'daily',
  }

  file { '/opt/mirrors/bin/healthcheck':
    source => 'puppet:///modules/ocf_mirrors/healthcheck',
    owner  => 'mirrors',
    group  => 'mirrors',
    mode   => '0755',
  }

  file {
    '/opt/ocfstats-password':
      content   => lookup('ocfstats::mysql::password'),
      mode      => '0600',
      owner     => 'root',
      group     => 'root',
      show_diff => false;

    '/usr/local/sbin/collect-mirrors-stats':
      source => 'puppet:///modules/ocf_mirrors/collect-mirrors-stats',
      mode   => '0755';
  } ->
  cron { 'mirrors-stats':
    command     => '/usr/local/sbin/collect-mirrors-stats --quiet --no-dry-run',
    minute      => 0,
    hour        => 0,
    environment => ['OCFSTATS_PWD__FILE=/opt/ocfstats-password'];
  }

  package { ['python3-prometheus-client']: }
  File<|title == '/srv/prometheus'|> {
    owner => 'mirrors',
    group => 'mirrors',
  }
}
