class ocf_admin::create::redis {
  package { ['redis-server', 'hitch']: }

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

  $redis_password = assert_type(Pattern[/^[a-zA-Z0-9]*$/], lookup('create::redis::password'))

  augeas { '/etc/redis/redis.conf':
    lens      => 'Spacevars.simple_lns',
    incl      => '/etc/redis/redis.conf',
    changes   =>  [
      'set port 6379',
      "set requirepass ${redis_password}",

      # Redis offers two data stores: RDB and AOF.
      # Supposedly AOF is more durable than RDB, so that's what we'll use.
      # We don't care at all how fast it is.
      #
      # http://redis.io/topics/persistence
      'set appendonly yes',
      'set appendfsync everysec',
      'rm save',
    ],
    show_diff => false,
    require   => File['/etc/redis/redis.conf'],
    notify    => Service['redis-server'];
  }

  # We already have an OCF member with the username "hitch", so dpkg
  # chooses "_hitch" as a fallback username.
  user { '_hitch':
    home    => '/etc/hitch',
    groups  => 'ssl-cert',
    notify  => Service['hitch'],
    require => Package['hitch'],
  }

  file { '/etc/hitch/hitch.conf':
    content => template('ocf_admin/hitch.conf.erb'),
    notify  => Service['hitch'],
    require => Package['hitch'],
  }

  service { 'hitch': }
}
