class ocf_admin {
  include ocf::extrapackages
  include ocf::ldapvi
  include ocf::mysql

  include apt_dater
  include create

  package {
    # remove accidentally-installed packages
    ['php5', 'libapache2-mod-php5', 'apache2']:
      ensure => purged;
  }

  class { 'ocf::nfs':
    pykota => true,
    cron   => true,
    web    => true;
  }

  class { 'ocf::docker':
    admin_group => 'ocfroot';
  }

  service { 'rsyslog': }

  user { 'atool':
    comment  => 'OCF Account Creation',
    gid      => approve,
    home     => '/srv/atool',
    system   => true,
    groups   => ['sys'];
  }

  # log directory, crontab, and keytab for create
  file {
    '/opt/create/private':
      ensure  => 'directory',
      owner   => 'atool',
      group   => 'approve',
      mode    => '0750';

    '/opt/create/private/backup':
      ensure  => 'directory',
      owner   => 'atool',
      group   => 'approve',
      mode    => '0750';

    '/etc/cron.d/create':
      source => 'puppet:///modules/ocf_admin/create.cron';

    '/opt/create/private/create.keytab':
      owner  => 'atool',
      group  => 'approve',
      mode   => '0400',
      source => 'puppet:///private/create.keytab';

    '/opt/create/private/mid_approved.users':
      ensure => 'file',
      owner  => 'atool',
      group  => 'approve',
      mode   => '0640';

    '/opt/create/private/private_pass.pem':
      ensure => 'file',
      owner  => 'atool',
      group  => 'approve',
      mode   => '0400',
      source => 'puppet:///private/private_pass.pem';

    '/etc/sudoers.d/atool':
      mode   => '0440',
      source => 'puppet:///modules/ocf_admin/atool.sudoers';

    '/opt/acct/sorry':
      ensure => link,
      target => '/opt/share/utils/staff/acct/sorry';
  }

  # provide logrotate rule for account creation scripts
  file { '/etc/logrotate.d/account-creation':
    ensure => file,
    source => 'puppet:///modules/ocf_admin/logrotate/account-creation';
  }
}
