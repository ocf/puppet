class ocf_backups::rsnapshot {
  package { 'rsnapshot':; }

  file {
    '/opt/share/backups/rsnapshot.conf':
      source => 'puppet:///modules/ocf_backups/rsnapshot.conf';

    '/opt/share/backups/rsnapshot-zfs.conf':
      source => 'puppet:///modules/ocf_backups/rsnapshot-zfs.conf';

    '/opt/share/backups/rsnapshot-zfs-mysql.conf':
      source => 'puppet:///modules/ocf_backups/rsnapshot-zfs-mysql.conf';
    '/opt/share/backups/rsnapshot-zfs-pgsql.conf':
      source => 'puppet:///modules/ocf_backups/rsnapshot-zfs-pgsql.conf';
    '/opt/share/backups/rsnapshot-zfs-git.conf':
      source => 'puppet:///modules/ocf_backups/rsnapshot-zfs-git.conf';

    '/usr/local/sbin/backup-zfs.sh':
      source => 'puppet:///modules/ocf_backups/backup-zfs.sh',
      mode   => '0755';

    # TODO: update for ZFS
    '/opt/share/backups/check-rsnapshot-backups':
      source => 'puppet:///modules/ocf_backups/check-rsnapshot-backups',
      mode   => '0755';
  }


  # TODO: update times listed here after move to remote backups

  $rsnapshot = '/usr/local/sbin/backup-zfs.sh'

  cron {
    default:
      user   => root,
      minute => '0';

    # ZFS
    'rsnapshot-daily':
      command => $rsnapshot,
      hour    => '23';
  }
}
