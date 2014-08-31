class ocf_accounts::app {
  package {
    'gunicorn':
      provider => pip,
      ensure   => latest;

    # build dependencies for python modules
    ['libldap2-dev', 'libsasl2-dev']:;
  }

  user { 'atool':
    comment  => 'OCF Account Creation',
    home     => '/srv/atool',
    system   => true,
    groups   => ['sys'];
  }

  File {
    owner    => atool,
    group    => atool
  }

  file {
    ['/srv/atool', '/srv/atool/env', '/srv/atool/etc']:
      ensure   => directory;

    '/srv/atool/etc/settings.py':
      source   => 'puppet:///private/settings.py',
      mode     => 400;

    '/srv/atool/etc/chpass.keytab':
      source   => 'puppet:///private/chpass.keytab',
      mode     => 400;

    '/srv/atool/etc/atool-id_rsa':
      source   => 'puppet:///private/atool-id_rsa',
      mode     => 400;

    '/srv/atool/etc/gunicorn.py':
      source   => 'puppet:///modules/ocf_accounts/atool/gunicorn.py',
      mode     => 444;

    '/srv/atool/etc/ssh_known_hosts':
      source   => 'puppet:///modules/ocf_accounts/atool/ssh_known_hosts',
      mode     => 444;

    # supervise app with daemontools
    '/etc/service/atool':
      ensure   => directory,
      mode     => 755;

    '/etc/service/atool/run':
      source   => 'puppet:///modules/ocf_accounts/atool/run',
      mode     => 755;

    # src is a symlink to the current deployed source;
    #
    # puppet will initially point it at the master branch, but will not
    # override it if changed, allowing you to point it at your own environment
    '/srv/atool/src':
      ensure   => link,
      links    => manage,
      target   => '/srv/atool/env/master',
      replace  => false;

    '/srv/atool/env/master/account_tools/settings.py':
      ensure   => link,
      links    => manage,
      target   => '/srv/atool/etc/settings.py',
      require  => Vcsrepo['/srv/atool/env/master'];
  }

  vcsrepo { '/srv/atool/env/master':
    provider => git,
    ensure   => latest,
    revision => 'master',
    source   => 'https://github.com/ocf/account-tools.git';
  }
}
