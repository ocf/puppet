class ocf_accounts::app {
  user { 'atool':
    comment => 'OCF Account Creation',
    gid     => approve,
    home    => '/opt/create',
    system  => true,
    groups  => ['sys'];
  }

  # ocf-atool package is installed in our apt repository and sets up gunicorn
  # running on localhost:8000
  package { 'ocf-atool':
    require => User['atool'];
  }

  service { 'ocf-atool':
    require => Package['ocf-atool'];
  }

  # TODO: on dev-accounts, we want staff to be able to read these too
  File {
    owner => atool,
    group => root
  }

  file {
    '/etc/ocf-atool/chpass.keytab':
      source  => 'puppet:///private/chpass.keytab',
      mode    => '0400',
      notify  => Service['ocf-atool'],
      require => Package['ocf-atool'];

    '/etc/ocf-atool/atool-id_rsa':
      source  => 'puppet:///private/atool-id_rsa',
      mode    => '0400',
      notify  => Service['ocf-atool'],
      require => Package['ocf-atool'];

    '/etc/ocf-atool/ssh_known_hosts':
      source  => 'puppet:///modules/ocf_accounts/atool/ssh_known_hosts',
      mode    => '0444',
      require => Package['ocf-atool'];
  }
}
