class ocf_admin::create::app {
  package { 'ocf-create':; }

  service { 'ocf-create':
    require => Package['ocf-create'];
  }

  $redis_password = file('/opt/puppet/shares/private/create/redis-password')
  validate_re($redis_password, '^[a-zA-Z0-9]*$', 'Bad Redis password')

  $broker = "redis+socket://:${redis_password}@/var/run/redis/redis.sock"
  $backend = $broker


  augeas { '/etc/ocf-create/ocf-create.conf':
    lens    => 'Puppet.lns',
    incl    => '/etc/ocf-create/ocf-create.conf',
    changes =>  [
      "set celery/broker ${broker}",
      "set celery/backend ${backend}",
    ],
    show_diff => false,
    notify  => Service['ocf-create'],
    require => Package['ocf-create'];
  }
}
