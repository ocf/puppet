class ocf_backups::git {
  file {
    '/opt/share/backups/backup-git':
      source => 'puppet:///modules/ocf_backups/backup-git',
      mode   => '0755';
  }
}
