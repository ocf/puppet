class ocf_backups::pgsql {
  file {
    '/opt/share/backups/backup-pgsql':
      source => 'puppet:///modules/ocf_backups/backup-pgsql',
      mode   => '0755';
  }
}
