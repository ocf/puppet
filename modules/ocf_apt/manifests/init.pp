class ocf_apt {
  include ocf::firewall::allow_web
  include ocf::ssl::default

  user { 'ocfapt':
    comment => 'OCF Apt',
    home    => '/opt/apt',
    shell   => '/bin/false',
  }

  package { 'reprepro':; }

  if $::host_env == 'prod' {
    $pkg_key = 'D72A0AF4'
  } else {
    $pkg_key = 'D0BA5B90'
  }

  file {
    default:
      owner => ocfapt,
      group => ocfapt;

    ['/opt/apt', '/opt/apt/ftp', '/opt/apt/etc', '/opt/apt/db']:
      ensure => directory,
      mode   => '0755';

    '/opt/apt/ftp/README.html':
      source => 'puppet:///modules/ocf_apt/README.html';

    '/opt/apt/etc/distributions':
      content => template('ocf_apt/distributions.erb');

    '/opt/apt/bin':
      ensure  => directory,
      source  => 'puppet:///modules/ocf_apt/bin/',
      mode    => '0755',
      recurse => true;

    '/etc/sudoers.d/ocfdeploy-apt':
      content => "ocfdeploy ALL=(ocfapt) NOPASSWD: /opt/apt/bin/reprepro, /opt/apt/bin/include-from-stdin, /opt/apt/bin/include-changes-from-stdin\n",
      owner   => root,
      group   => root;
  }

  ocf::privatefile { '/opt/apt/etc/private.key':
    source => 'puppet:///private/apt/private.key',
    owner  => 'ocfapt',
    group  => 'ocfapt',
    mode   => '0400';
  }

  exec {
    'import-apt-gpg':
      command     => 'rm -rf /opt/apt/.gnupg && gpg --import /opt/apt/etc/private.key',
      user        => ocfapt,
      refreshonly => true,
      subscribe   => Ocf::Privatefile['/opt/apt/etc/private.key'];

    'export-gpg-pubkey':
      command => 'gpg --output /opt/apt/ftp/pubkey.gpg --export D72A0AF4',
      creates => '/opt/apt/ftp/pubkey.gpg',
      require => Exec['import-apt-gpg'];

    'initial-reprepro-export':
      command => '/opt/apt/bin/reprepro export',
      user    => ocfapt,
      creates => '/opt/apt/ftp/dists',
      require => [
        Package['reprepro'],
        File['/opt/apt/bin', '/opt/apt/etc', '/opt/apt/db', '/opt/apt/ftp'],
        Exec['import-apt-gpg'],
        User['ocfapt'],
      ];
  }

  apache::vhost { 'apt.ocf.berkeley.edu':
    serveraliases     => ['apt'],
    port              => 80,
    docroot           => '/opt/apt/ftp',

    directories       => [{
      path          => '/opt/apt/ftp',
      options       => ['+Indexes', '+SymlinksIfOwnerMatch'],
      index_options => ['NameWidth=*', '+SuppressDescription']
    }],

    access_log_format => 'io_count',
    custom_fragment   => "HeaderName README.html\nReadmeName FOOTER.html",
  }

  apache::vhost { 'apt.ocf.berkeley.edu-ssl':
    servername        => 'apt.ocf.berkeley.edu',
    port              => 443,
    docroot           => '/opt/apt/ftp',

    directories       => [{
      path          => '/opt/apt/ftp',
      options       => ['+Indexes', '+SymlinksIfOwnerMatch'],
      index_options => ['NameWidth=*', '+SuppressDescription']
    }],

    access_log_format => 'io_count',
    custom_fragment   => "HeaderName README.html\nReadmeName FOOTER.html",

    ssl               => true,
    ssl_key           => "/etc/ssl/private/${::fqdn}.key",
    ssl_cert          => "/etc/ssl/private/${::fqdn}.crt",
    ssl_chain         => "/etc/ssl/private/${::fqdn}.intermediate",
  }
}
