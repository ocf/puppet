class ocf_accounts::app {
  user { 'atool':
    comment => 'OCF Account Tools',
    home    => '/opt',
    system  => true;
  }

  # ocf-atool package is installed in our apt repository and sets up gunicorn
  # running on localhost:8000
  package { 'ocf-atool':
    require => User['atool'];
  }

  $is_dev = $::hostname =~ /^dev-/

  # on dev, we don't run the app as a service;
  # instead, developers can launch it from the source tree
  $service_ensure = $is_dev ? {
    true  => stopped,
    false => running,
  }

  service { 'ocf-atool':
    ensure  => $service_ensure,
    require => Package['ocf-atool'];
  }

  $file_group = $is_dev ? {
    true  => ocfstaff,
    false => root,
  }
  File {
    owner => atool,
    group => $file_group,
  }

  file {
    '/etc/ocf-atool/chpass.keytab':
      source  => 'puppet:///private/chpass.keytab',
      mode    => '0440',
      notify  => Service['ocf-atool'],
      require => Package['ocf-atool'];

    # TODO: drop this and use Kerberos?
    '/etc/ocf-atool/ssh_known_hosts':
      source  => 'puppet:///modules/ocf_accounts/atool/ssh_known_hosts',
      mode    => '0444',
      require => Package['ocf-atool'];

    '/etc/ocf-atool/create.pub':
      owner   => atool,
      group   => root,
      mode    => '0444',
      source  => 'puppet:///private/create.pub',
      require => Package['ocf-atool'];

    # just changing group
    '/etc/ocf-atool/ocf-atool.conf':
      require => Package['ocf-atool'];
  }

  # TODO: stop copy-pasting this everywhere
  $redis_password = file('/opt/puppet/shares/private/create/redis-password')
  validate_re($redis_password, '^[a-zA-Z0-9]*$', 'Bad Redis password')
  $django_secret = file("/opt/puppet/shares/private/${::hostname}/django-secret")
  validate_re($django_secret, '^[a-zA-Z0-9]*$', 'Bad Django secret')

  $broker = "redis://:${redis_password}@localhost:6379"
  $backend = $broker

  augeas { '/etc/ocf-atool/ocf-atool.conf':
    lens      => 'Puppet.lns',
    incl      => '/etc/ocf-atool/ocf-atool.conf',
    changes   =>  [
      "set django/secret ${django_secret}",
      "set celery/broker ${broker}",
      "set celery/backend ${backend}",
    ],
    show_diff => false,
    notify    => Service['ocf-atool'],
    require   => Package['ocf-atool'];
  }

  file { '/var/run/redis.sock':
    mode => '0664';
  }
  spiped::tunnel::client { 'redis':
    source  => 'localhost:6379',
    dest    => 'create:6379',
    secret  => file('/opt/puppet/shares/private/create/spiped-key'),
    require => File['/var/run/redis.sock'];
  }
}
