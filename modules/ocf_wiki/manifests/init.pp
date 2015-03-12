class ocf_wiki {
  include ocf_ssl

  # for ikiwiki and ikiwiki search
  package { [ 'ikiwiki', 'xapian-omega', 'libsearch-xapian-perl' ]: }
  package { ['libyaml-perl']: }

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
    source => 'puppet:///modules/ocf_wiki/ikiwiki/plugins/serverlist.pm',
  }

  # the location of the wiki public_html
  file {
    '/srv/ikiwiki/public_html':
      ensure => directory,
      owner  => root,
      group  => root,
      mode   => '0755';

    '/srv/ikiwiki/public_html/wiki':
      ensure  => 'directory',
      owner   => 'www-data',
      mode    => '0755';

    '/srv/ikiwiki/public_html/webhook':
      ensure  => directory,
      owner   => root,
      mode    => '0755';
  }

  ocf::webhook { '/srv/ikiwiki/public_html/webhook/github.cgi':
    service    => 'github',
    secretfile => '/opt/share/webhook/secrets/github.secret',
    command    => '/srv/ikiwiki/rebuild-wiki';
  }

  file {
    '/srv/ikiwiki/wiki.git':
      ensure  => 'directory',
      owner   => 'www-data';
  }

  # the lockfile is necessary for 'ikiwiki --setup'
  file {
    '/srv/ikiwiki/wiki':
      ensure  => 'directory',
      owner   => 'www-data';
  }
  file {
    '/srv/ikiwiki/wiki/.ikiwiki':
      ensure  => 'directory',
      owner   => 'www-data',
      mode    => '0775';
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

  file {
    # holds no secrets
    '/srv/ikiwiki/wiki.setup':
      source => 'puppet:///modules/ocf_wiki/ikiwiki/wiki.setup',
      owner  => root,
      group  => root,
      mode   => '0644';

    '/srv/ikiwiki/rebuild-wiki':
      source => 'puppet:///modules/ocf_wiki/rebuild-wiki',
      owner  => root,
      mode   => '0755';

    '/opt/share/webhook/secrets/github.secret':
      source => 'puppet:///private/github.secret',
      owner  => root,
      group  => www-data,
      mode   => '0640';
  }

  service { 'apache2':
    subscribe => File[ '/etc/apache2/sites-available/ikiwiki',
      '/etc/apache2/sites-enabled/ikiwiki'];
  }

  file {
    '/etc/apache2/sites-available/ikiwiki':
      source => 'puppet:///modules/ocf_wiki/apache2/ikiwiki';
    '/etc/apache2/sites-enabled/ikiwiki':
      ensure => symlink,
      links  => manage,
      target => '/etc/apache2/sites-available/ikiwiki';
  }

  # old wiki (docs)
  file { '/etc/apache2/sites-available/docs':
    ensure => file,
    source => 'puppet:///modules/ocf_wiki/apache2/docs',
  }
  exec { '/usr/sbin/a2ensite docs':
    unless  => '/bin/readlink -e /etc/apache2/sites-enabled/docs',
    notify  => Service['apache2'],
    require => File['/etc/apache2/sites-available/docs'],
  }

  # default wiki site
  file { '/etc/apache2/sites-available/000-default':
    ensure => file,
    source => 'puppet:///modules/ocf_wiki/apache2/000-default',
  }
  exec { '/usr/sbin/a2ensite default':
    unless  => '/bin/readlink -e /etc/apache2/sites-enabled/000-default',
    notify  => Service['apache2'],
    require => File['/etc/apache2/sites-available/000-default'],
  }
}
