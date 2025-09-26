class ocf_admin::create {
  package { 'ocf-approve':; }

  $redis_create_password = lookup('broker::redis::password')
  $mysql_create_password = lookup('create::mysql::password')
  file {
    '/etc/ocf-create':
      ensure => directory;

    '/etc/ocf-create/ocf-create.conf':
      group     => ocfroot,
      content   => template('ocf_admin/create.conf.erb'),
      mode      => '0440',
      show_diff => false;
  }

  ocf::privatefile {
    '/etc/ocf-create/create.keytab':
      mode   => '0400',
      source => 'puppet:///private/create.keytab';

    '/etc/ocf-create/create.key':
      mode   => '0400',
      source => 'puppet:///private/create.key';

    '/etc/ocf-create/create.pub':
      mode   => '0444',
      source => 'puppet:///private/create.pub';
  }
}
