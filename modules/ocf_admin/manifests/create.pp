class ocf_admin::create {
  package { 'ocf-approve':; }

  file {
    '/etc/ocf-create':
      ensure => directory;

    # TODO: ideally this file wouldn't be directly readable by staff
    '/etc/ocf-create/ocf-create.conf':
      group  => ocfstaff,
      source => 'puppet:///private/create.conf',
      mode   => '0440';

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

  # temporary, for removing the old redis
  package { 'redis-server':
    ensure => 'absent',
  }

  package { 'hitch':
    ensure => 'absent',
  }

  user { '_hitch':
    ensure => 'absent',
  }
}
