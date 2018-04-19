class ocf_broker {
    include ocf_ssl::default_bundle

    package { ['redis-server', 'hitch']: }

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

    $redis_password = assert_type(Pattern[/^[a-zA-Z0-9]*$/], hiera('broker::redis::password'))

    augeas { '/etc/redis/redis.conf':
        lens      => 'Spacevars.simple_lns',
        incl      => '/etc/redis/redis.conf',
        changes   => [
          'set port 6379',
          "set requirepass ${redis_password}",
          'set appendonly yes',
          'rm save',
        ],
        show_diff => false,
        require   => File['/etc/redis/redis.conf'],
        notify    => Service['redis-server'];
    }

    # We already have an OCF member with the username "hitch", so dpkg
    # chooses "_hitch" as a fallback username.
    user { '_hitch':
      groups  => 'ssl-cert',
      notify  => Service['hitch'],
      require => Package['hitch'],
    }

    file { '/etc/hitch/hitch.conf':
      content => template('ocf_broker/hitch.conf.erb'),
      notify  => Service['hitch'],
      require => Package['hitch'],
    }

    service { 'hitch':
      require => [ Package['hitch'], Service['redis-server']];
    }
}
