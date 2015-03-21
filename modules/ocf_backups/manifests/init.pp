class ocf_backups {
  include ocf_backups::mysql
  include ocf_backups::rsnapshot

  file {
    '/opt/share/backups':
      ensure => directory;
  }
}
