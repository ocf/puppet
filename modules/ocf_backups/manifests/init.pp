class ocf_backups {
  include ocf_backups::mysql

  file {
    '/opt/share/backups':
      ensure => directory;
  }
}
