class supernova {

  package {
    # account creation dependecies
    ['python-twisted', 'python-argparse', 'python-crypto']:
    ;
  }

  service { 'rsyslog': }

  # log directory, crontab, and keytab for create
  file {
    '/opt/create/private':
      ensure  => 'directory',
      owner   => 'create',
      group   => 'approve',
      recurse => true,
      mode    => '0750';

    '/etc/cron.d/create':
      source => 'puppet:///modules/supernova/create.cron';

    '/opt/create/private/create.keytab':
      owner  => 'create',
      group  => 'approve',
      mode   => '0400',
      source => 'puppet:///private/create.keytab';

    '/opt/create/private/mid_approved.users':
      ensure => 'file',
      owner  => 'create',
      group  => 'approve',
      mode   => '0640';

    '/opt/create/private/private_pass.pem':
      ensure => 'file',
      owner  => 'create',
      group  => 'approve',
      mode   => '0400',
      source => 'puppet:///private/private_pass.pem';

    '/etc/sudoers.d/create':
      mode   => '0440',
      source => 'puppet:///modules/supernova/create.sudoers';
  }

  # user for account creation
  user { 'create':
    home     => '/opt/create/private',
    shell    => '/bin/false',
    uid      => 501,
    gid      => 1002, # group = approve
    comment  => 'OCF account creation user',
    ensure   => 'present',
  }

  # receive remote syslog from tsunami
  file { '/etc/rsyslog.d/tsunami.conf':
    content => "if \$FROMHOST startswith 'tsunami' then /var/log/tsunami.log\n& ~\n",
    notify  => Service['rsyslog'],
  }

  # provide logrotate rule for account creation scripts
  file { '/etc/logrotate.d/account-creation':
    ensure => file,
    source => 'puppet:///modules/supernova/logrotate/account-creation';
  }
}
