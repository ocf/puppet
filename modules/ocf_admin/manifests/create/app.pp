class ocf_admin::create::app {
  package { 'ocf-approve':; }

  # these get shoved into URIs, and we can't deal with escaping
  $redis_password = file('/opt/puppet/shares/private/create/redis-password')
  validate_re($redis_password, '^[a-zA-Z0-9]*$', 'Bad Redis password')
  $mysql_password = file('/opt/puppet/shares/private/create/mysql-password')
  validate_re($mysql_password, '^[a-zA-Z0-9]*$', 'Bad MySQL password')

  $broker = "redis://:${redis_password}@admin.ocf.berkeley.edu:6378"
  $backend = $broker

  $redis_uri = "rediss://:${redis_password}@admin.ocf.berkeley.edu:6378"

  # TODO: provide this entire file (rt#5887)
  augeas { '/etc/ocf-create/ocf-create.conf':
    lens      => 'Puppet.lns',
    incl      => '/etc/ocf-create/ocf-create.conf',
    changes   =>  [
      "set mysql/uri mysql+pymysql://ocfcreate:${mysql_password}@mysql/ocfcreate",
      "set celery/broker ${broker}",
      "set celery/backend ${backend}",
      "set redis/uri ${redis_uri}",
    ],
    show_diff => false,
  }

  file {
    '/etc/ocf-create':
      ensure => directory;

    # TODO: ideally this file wouldn't be directly readable by staff
    '/etc/ocf-create/ocf-create.conf':
      owner  => create,
      group  => ocfstaff,
      mode   => '0440';

    '/etc/ocf-create/create.keytab':
      owner  => create,
      mode   => '0400',
      source => 'puppet:///private/create.keytab';

    '/etc/ocf-create/create.key':
      owner  => create,
      mode   => '0400',
      source => 'puppet:///private/create.key';

    '/etc/ocf-create/create.pub':
      owner  => create,
      mode   => '0444',
      source => 'puppet:///private/create.pub';
  }
}
