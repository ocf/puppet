class ocf_backups::pgsql {
  include ocf::packages::postgres

  file {
    '~/.pgpass':
      source    => 'puppet:///private/backups/.pgpass',
      mode      => '0600',
      show_diff => false;

    '/opt/share/backups/backup-pgsql':
      source => 'puppet:///modules/ocf_backups/backup-pgsql',
      mode   => '0755';
  }
}
