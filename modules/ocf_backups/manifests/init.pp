class ocf_backups {
  include ocf_backups::mysql
  include ocf_backups::rsnapshot

  file {
    '/opt/share/backups':
      ensure => directory;

    # keytab for ocfbackups user, used to rsync from remote servers
    '/opt/share/backups/ocfbackups.keytab':
      source => 'puppet:///private/ocfbackups.keytab',
      mode   => '0600';
  }
}
