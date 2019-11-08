class ocf_broker {
    include ocf::ssl::default

    package { ['redis-server', 'haproxy']: }

    service { 'redis-server':
      require => Package['redis-server'],
    }

    file { '/etc/redis/redis.conf':
      owner   => redis,
      group   => root,
      mode    => '0600',
      require => Package['redis-server'],
      notify  => Service['redis-server'];
    }

    $redis_password = assert_type(Pattern[/^[a-zA-Z0-9]*$/], lookup('broker::redis::password'))

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

    file { '/etc/haproxy/haproxy.cfg':
      content => template('ocf_broker/haproxy.cfg.erb'),
      notify  => Service['haproxy'],
      require => Package['haproxy'],
    }

    service { 'haproxy':
      require   => [Package['haproxy'], Service['redis-server']],
      subscribe => Class['ocf::ssl::default'],
    }

    # firewall input rule, allow redis
    firewall_multi {
      '101 allow redis (IPv4)':
        chain     => 'PUPPET-INPUT',
        src_range => lookup('desktop_src_range_4'),
        proto     => 'tcp',
        dport     => 6378,
        action    => 'accept';

      '101 allow redis (IPv6)':
        chain     => 'PUPPET-INPUT',
        src_range => lookup('desktop_src_range_6'),
        proto     => 'tcp',
        action    => 'accept',
        dport     => 6378,
        provider  => 'ip6tables';
    }
}
