class ocf_admin::create::redis {
  package { ['redis-server']: }

  service { 'redis-server':
    require => Package['redis-server'],
  }

  # By default, this is world-readable. And we want to stuff secrets into it.
  file { '/etc/redis/redis.conf':
    owner   => redis,
    group   => root,
    mode    => '0600',
    require => Package['redis-server'],
    notify  => Service['redis-server'];
  }

  $redis_password = file('/opt/puppet/shares/private/create/redis-password')
  validate_re($redis_password, '^[a-zA-Z0-9]*$', 'Bad Redis password')

  augeas { '/etc/redis/redis.conf':
    lens    => 'Spacevars.simple_lns',
    incl    => '/etc/redis/redis.conf',
    changes =>  [
      'set port 0',
      "set requirepass ${redis_password}",
      'set unixsocket /var/run/redis/redis.sock',
      'set unixsocketperm 666',

      # Redis offers two data stores: RDB and AOF.
      # Supposedly AOF is more durable than RDB, so that's what we'll use.
      # We don't care at all how fast it is.
      #
      # http://redis.io/topics/persistence
      'set appendonly yes',
      'set appendfsync always',
      'rm save',
    ],
    show_diff => false,
    require => File['/etc/redis/redis.conf'],
    notify  => Service['redis-server'];
  }

  ocf::repackage { 'stunnel4': backport_on => jessie } ->
  augeas { '/etc/default/stunnel4':
    lens    => 'Shellvars.lns',
    incl    => '/etc/default/stunnel4',
    changes =>  ['set ENABLED 1'],
  } ~>
  file { '/etc/stunnel/redis.conf':
    content => template('ocf_admin/stunnel/redis.conf.erb'),
  } ~>
  service { 'stunnel4': }
}
