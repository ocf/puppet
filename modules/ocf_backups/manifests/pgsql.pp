class ocf_backups::pgsql {
  include ocf::packages::postgres

  file {
    '/opt/share/backups/backup-pgsql':
      source => 'puppet:///modules/ocf_backups/backup-pgsql',
      mode   => '0755';
  }
}
