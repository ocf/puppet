class ocf_mirrors {
  include ocf_ssl::default_bundle
  require ocf::packages::rsync

  include ocf_mirrors::ftp
  include ocf_mirrors::rsync

  # projects
  include ocf_mirrors::apache
  include ocf_mirrors::archlinux
  include ocf_mirrors::centos
  include ocf_mirrors::debian
  include ocf_mirrors::finnix
  include ocf_mirrors::gnu
  include ocf_mirrors::kali
  include ocf_mirrors::kde
  include ocf_mirrors::manjaro
  include ocf_mirrors::parrot
  include ocf_mirrors::puppetlabs
  include ocf_mirrors::qt
  include ocf_mirrors::raspbian
  include ocf_mirrors::tails
  include ocf_mirrors::tanglu
  include ocf_mirrors::trisquel
  include ocf_mirrors::ubuntu

  user { 'mirrors':
    comment  => 'OCF Mirroring',
    home     => '/opt/mirrors',
    groups   => ['sys'],
    shell    => '/bin/bash',
    system   => true,

    # Set to have no password, only allow key-based login
    password => '*',
  }

  $ocfstats_password = hiera('ocfstats::mysql::password')

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
  }

  class {
    '::apache':
      default_vhost => false,
      keepalive     => 'on',
      log_formats   => {
        # A custom log format that counts bytes transferred by accesses (mod_logio)
        io_count => '%h %l %u %t \"%r\" %>s %b \"%{Referer}i\" \"%{User-Agent}i\" %I %O',
      },
      # "false" lets us define the class below with custom args
      mpm_module    => false;

    '::apache::mod::worker':
      startservers    => 8,
      # maxclients should be set to a max of serverlimit * threadsperchild
      maxclients      => 5000,
      threadsperchild => 50,
      serverlimit     => 100;
  }
  include apache::mod::headers
  include apache::mod::status

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

  # Tails asked us to turn off ETags.
  $tails_project_directory_options = {
    path          => '/opt/mirrors/ftp/tails',
    headers       => 'unset ETag',

    # TODO: Submit a PR for puppetlabs-apache to support changing etags in
    # directories. They can be canged in the vhost config currently, but not
    # per directory.
    custom_fragment => 'FileETag none',
  }

  apache::vhost { 'mirrors.ocf.berkeley.edu':
    serveraliases   => ['mirrors', 'dl.amnesia.boum.org', '*.dl.amnesia.boum.org'],
    port            => 80,
    default_vhost   => true,
    docroot         => '/opt/mirrors/ftp',

    directories     => [
      {
        path          => '/opt/mirrors/ftp',
        options       => ['+Indexes', '+SymlinksIfOwnerMatch'],
        index_options => ['NameWidth=*', '+SuppressDescription']
      },
      $apache_project_directory_options,
      $tails_project_directory_options,
    ],

    access_log_format => 'io_count',
    custom_fragment   => "
      HeaderName README.html
      ReadmeName FOOTER.html
    ",
  }

  apache::vhost { 'mirrors.berkeley.edu':
    port            => 80,

    # we have to specify docroot even though we always redirect
    docroot         => '/var/www',

    redirect_source => '/',
    redirect_dest   => 'http://mirrors.ocf.berkeley.edu/',
    redirect_status => '301',
  }

  apache::vhost { 'mirrors.ocf.berkeley.edu-ssl':
    servername      => 'mirrors.ocf.berkeley.edu',
    port            => 443,
    docroot         => '/opt/mirrors/ftp',

    directories     => [
      {
        path          => '/opt/mirrors/ftp',
        options       => ['+Indexes', '+SymlinksIfOwnerMatch'],
        index_options => ['NameWidth=*', '+SuppressDescription']
      },
      $apache_project_directory_options,
      $tails_project_directory_options,
    ],

    access_log_format => 'io_count',
    custom_fragment   => "
      HeaderName README.html
      ReadmeName FOOTER.html
    ",

    ssl       => true,
    ssl_key   => "/etc/ssl/private/${::fqdn}.key",
    ssl_cert  => "/etc/ssl/private/${::fqdn}.crt",
    ssl_chain => '/etc/ssl/certs/incommon-intermediate.crt',
  }

  file { '/opt/mirrors/bin/report-sizes':
    source => 'puppet:///modules/ocf_mirrors/report-sizes',
    mode   => '0755',
  } ->
  cron { 'report-sizes':
    command => '/opt/mirrors/bin/report-sizes',
    special => 'daily',
  }

  file { '/usr/local/sbin/process-mirrors-logs':
    source => 'puppet:///modules/ocf_mirrors/process-mirrors-logs',
    mode   => '0755',
  } ->
  cron { 'mirrors-stats':
    command => '/usr/local/sbin/process-mirrors-logs --quiet',
    minute  => 0,
    hour    => 0,
    environment => ["OCFSTATS_PWD=${ocfstats_password}"];
  }
}
