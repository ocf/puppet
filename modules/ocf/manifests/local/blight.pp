class ocf::local::blight {

  # for ikiwiki and ikiwiki search
  package { [ 'ikiwiki', 'xapian-omega', 'libsearch-xapian-perl' ]: }
  package { ['libyaml-perl']: }

  package { 'gitweb': }

  # for old wiki
  package { ['php5', 'php5-cli', 'php5-mysql']: }

  # the location of ikwiki
  file { '/srv/ikiwiki':
    ensure => 'directory',
    owner  => 'root',
    group  => 'ocfstaff',
    mode   => '0775',
  }

  # the serverlist ikiwiki plugin needs to be in a certain folder
  file {
    '/srv/ikiwiki/.ikiwiki/IkiWiki/Plugin':
      ensure  => 'directory',
      owner   => 'root',
      group   => 'ocfstaff',
      recurse => true,
      mode    => '0775';
    '/srv/ikiwiki/.ikiwiki/IkiWiki':
      ensure  => 'directory';
    '/srv/ikiwiki/.ikiwiki':
      ensure  => 'directory';
  }
  file { '/srv/ikiwiki/.ikiwiki/IkiWiki/Plugin/serverlist.pm':
    source => 'puppet:///modules/ocf/local/blight/ikiwiki/plugins/serverlist.pm',
  }


  # the location of the wiki public_html
  file {
    '/srv/ikiwiki/public_html/wiki':
      ensure  => 'directory',
      require => Exec['ikiwiki_setup'],
      owner   => 'www-data',
      group   => 'ocfstaff',
#      mode    => '0775',
      recurse => true;
    '/srv/ikiwiki/public_html/wiki/ikiwiki.cgi':
      owner   => 'www-data',
      group   => 'ocfstaff',
      mode    => '2760';
  }

  file {
    '/srv/ikiwiki/wiki.git':
      ensure  => 'directory',
      owner   => 'www-data',
      group   => 'ocfstaff',
      recurse => true;
    '/srv/ikiwiki/wiki.git/description':
      content => 'wiki.OCF ikiwiki pages';
  }

  # the config file replaces the default
  file {
    '/srv/ikiwiki/wiki.git/config':
      source  => 'puppet:///modules/ocf/local/blight/ikiwiki/git_config',
      owner   => 'root',
      group   => 'ocfstaff',
      mode    => '0775';
    '/srv/ikiwiki/wiki.git/hooks/post-update':
      mode    => '2775',
      owner   => 'root',
      group   => 'ocfstaff';
  }

  # the lockfile is necessary for 'ikiwiki --setup'
  file {
    '/srv/ikiwiki/wiki':
      ensure  => 'directory',
      owner   => 'www-data',
      group   => 'ocfstaff',
#      mode    => '0775';
      recurse => true,
  }
  file {
    '/srv/ikiwiki/wiki/.ikiwiki':
      ensure  => 'directory',
      owner   => 'www-data',
      group   => 'ocfstaff',
      mode    => '0775',
      recurse => true;
  }

  exec { 'ikiwiki_setup':
    require => File[ '/srv/ikiwiki/wiki.setup'],
    command => 'ikiwiki --setup wiki.setup',
    creates => '/srv/ikiwiki/public_html/wiki',
    cwd     => '/srv/ikiwiki',
  }

  exec { 'refresh_ikiwiki_setup':
    require     => File[ '/srv/ikiwiki/wiki.setup'],
    command     => 'ikiwiki --setup wiki.setup',
    cwd         => '/srv/ikiwiki',
    subscribe   => File['/srv/ikiwiki/wiki.setup'],
    refreshonly => true,
  }

  file { '/srv/ikiwiki/wiki.setup':
    source => 'puppet:///modules/ocf/local/blight/ikiwiki/wiki.setup',
    owner  => 'root',
    group  => 'ocfstaff',
    mode   => '0640',
  }

  service { 'apache2':
    subscribe => File[ '/etc/apache2/sites-available/ikiwiki',
      '/etc/apache2/sites-enabled/ikiwiki',
      '/etc/apache2/sites-available/gitweb',
      '/etc/apache2/sites-enabled/gitweb' ],
  }

  file {
    '/etc/apache2/sites-available/ikiwiki':
      source => 'puppet:///modules/ocf/local/blight/apache2/ikiwiki';
    '/etc/apache2/sites-enabled/ikiwiki':
      ensure => symlink,
      target => '/etc/apache2/sites-available/ikiwiki';
    '/etc/apache2/sites-available/gitweb':
      source => 'puppet:///modules/ocf/local/blight/apache2/gitweb';
    '/etc/apache2/sites-enabled/gitweb':
      ensure => symlink,
      target => '/etc/apache2/sites-available/gitweb';
    #'/etc/apache2/sites-enabled/000-default':
    #  ensure => absent;
  }

  # gitweb setup
  file {
    '/srv/gitweb':
      ensure  => symlink,
      target  => '/usr/share/gitweb';
    '/srv/gitweb/projects.list':
      content => 'wiki.git';
    '/etc/gitweb.conf':
      source  => 'puppet:///modules/ocf/local/blight/gitweb/gitweb.conf';
  }

  # old wiki (docs)
  file { '/etc/apache2/sites-available/docs':
    source      => 'puppet:///modules/ocf/local/blight/apache2/docs',
    ensure      => file,
  }
  exec { '/usr/sbin/a2ensite docs':
    unless      => '/bin/readlink -e /etc/apache2/sites-enabled/docs',
    notify      => Service['apache2'],
    require     => File['/etc/apache2/sites-available/docs'],
  }

  # default blight site
  file { '/etc/apache2/sites-available/000-default':
    source      => 'puppet:///modules/ocf/local/blight/apache2/000-default',
    ensure      => file,
  }
  exec { '/usr/sbin/a2ensite default':
    unless      => '/bin/readlink -e /etc/apache2/sites-enabled/000-default',
    notify      => Service['apache2'],
    require     => File['/etc/apache2/sites-available/000-default'],
  }
}
