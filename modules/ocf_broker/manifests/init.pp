class ocf_broker {
    package { ['redis-server']: }

    service { 'redis-server':
      require => Package['redis-server'],
    }

    file { '/etc/redis/redis.conf':
      owner    => redis,
      group    => root,
      mode     => '0600',
      require  => Package['redis-server'],
      notify   => Service['redis-server'];
    }

    $redis_password = assert_type(Pattern[/^[a-zA-Z0-9]*$/], hiera('ocfbroker::redis::password'))

    augeas { '/etc/redis/redis.conf':
        lens      => 'Spacevars.simple_lns',
        incl      => '/etc/redis/redis.conf',
        changes   => [
          'set port 6379',
          "set requirepass ${redis_password}",
          'set appendonly yes',
          'set appendfsynch everysec',
          'rm save',
        ],
        show_diff => false,
        require   => File['/etc/redis/redis.conf'],
        notify    => Service['redis-server'];
    }
}
