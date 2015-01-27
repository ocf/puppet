class ocf_accounts::app {
  package {
    'gunicorn':
      ensure   => latest,
      provider => pip3;

    # build dependencies for python modules
    ['libldap2-dev', 'libsasl2-dev']:;
  }

  user { 'atool':
    comment => 'OCF Account Creation',
    gid     => approve,
    home    => '/srv/atool',
    system  => true,
    groups  => ['sys'];
  }

  File {
    owner => atool,
    group => approve
  }

  file {
    ['/srv/atool', '/srv/atool/env', '/srv/atool/etc']:
      ensure => directory;

    '/srv/atool/etc/settings.py':
      source => 'puppet:///private/settings.py',
      mode   => '0400',
      notify => Exec['reload-atool'];

    '/srv/atool/etc/chpass.keytab':
      source => 'puppet:///private/chpass.keytab',
      mode   => '0400';

    '/srv/atool/etc/atool-id_rsa':
      source => 'puppet:///private/atool-id_rsa',
      mode   => '0400';

    '/srv/atool/etc/gunicorn.py':
      source => 'puppet:///modules/ocf_accounts/atool/gunicorn.py',
      mode   => '0444';

    '/srv/atool/etc/ssh_known_hosts':
      source => 'puppet:///modules/ocf_accounts/atool/ssh_known_hosts',
      mode   => '0444';

    # supervise app with daemontools
    '/etc/service/atool':
      ensure => directory,
      mode   => '0755';

    '/etc/service/atool/run':
      source => 'puppet:///modules/ocf_accounts/atool/run',
      mode   => '0755';

    # src is a symlink to the current deployed source;
    #
    # puppet will initially point it at the master branch, but will not
    # override it if changed, allowing you to point it at your own environment
    '/srv/atool/src':
      ensure  => link,
      links   => manage,
      target  => '/srv/atool/env/master',
      replace => false;

    '/srv/atool/env/master/atool/settings.py':
      ensure  => link,
      links   => manage,
      target  => '/srv/atool/etc/settings.py',
      require => Vcsrepo['/srv/atool/env/master'];

    ['/opt/create', '/opt/create/public']:
      ensure  => directory;
  }

  exec { 'reload-atool':
    command     => 'svc -h /etc/service/atool',
    refreshonly => true;
  }

  vcsrepo { '/srv/atool/env/master':
    ensure   => latest,
    provider => git,
    revision => 'master',
    source   => 'https://github.com/ocf/atool.git',
    owner => atool,
    group => approve;
  }
}
