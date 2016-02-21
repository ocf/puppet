class ocf_backups {
  include ocf_backups::git
  include ocf_backups::mysql
  include ocf_backups::offsite
  include ocf_backups::rsnapshot

  file {
    '/opt/share/backups':
      ensure => directory;

    ['/opt/backups', '/opt/backups/live', '/opt/backups/scratch']:
      ensure => directory,
      group  => ocfroot,
      mode   => '0750';

    # keytab for ocfbackups user, used to rsync from remote servers
    '/opt/share/backups/ocfbackups.keytab':
      source => 'puppet:///private/ocfbackups.keytab',
      mode   => '0600';
  }
}
