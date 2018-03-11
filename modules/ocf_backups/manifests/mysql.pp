class ocf_backups::mysql {
  include ocf::packages::mysql

  file {
    '/opt/share/backups/my.cnf':
      source    => 'puppet:///private/backups/my.cnf',
      mode      => '0600',
      show_diff => false;

    '/opt/share/backups/backup-mysql':
      source => 'puppet:///modules/ocf_backups/backup-mysql',
      mode   => '0755';
  }
}
