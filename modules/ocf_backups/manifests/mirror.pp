# The backups mirror is a separate server which is responsible for mirroring
# backups from the main backups server, and periodically uploading backup
# snapshots to an off-site location.
class ocf_backups::mirror {
  file {
    ['/opt/backups', '/opt/backups/mirror', '/opt/backups/scratch']:
      ensure => directory,
      group  => ocfroot,
      mode   => '0750';
  }
}
