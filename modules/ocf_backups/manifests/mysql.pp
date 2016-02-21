class ocf_backups::mysql {
  package { 'mysql-client':; }
  file {
    '/opt/share/backups/my.cnf':
      source => 'puppet:///private/backups/my.cnf',
      mode   => '0600';

    '/opt/share/backups/backup-mysql':
      source => 'puppet:///modules/ocf_backups/backup-mysql',
      mode   => '0755';
  }
}
