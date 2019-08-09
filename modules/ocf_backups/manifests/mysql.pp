class ocf_backups::mysql {
  include ocf::packages::mysql

  $ocfbackups_mysql_password = lookup('ocfbackups::mysql::password')
  file {
    '/opt/share/backups/my.cnf':
      content   => template('ocf_backups/my.cnf.erb'),
      mode      => '0600',
      show_diff => false;

    '/opt/share/backups/backup-mysql':
      source => 'puppet:///modules/ocf_backups/backup-mysql',
      mode   => '0755';
  }
}
