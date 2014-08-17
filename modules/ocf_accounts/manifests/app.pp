class ocf_accounts::app {
  package { 'gunicorn':
    provider => pip,
    ensure   => latest;
  }

  user { 'atool':
    comment  => 'OCF Account Creation',
    home     => '/srv/atool',
    system   => true,
    groups   => ['sys'];
  }

  file {
    '/srv/atool':
      ensure   => directory,
      require  => User['atool'],
      owner    => atool,
      group    => atool;

    # supervise app with daemontools
    '/etc/service/atool':
      ensure   => directory,
      mode     => 755;

    '/etc/service/atool/run':
      source   => 'puppet:///modules/ocf_accounts/atool/run',
      mode     => 755;
  }
}
