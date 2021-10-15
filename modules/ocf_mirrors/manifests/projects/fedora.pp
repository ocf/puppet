class ocf_mirrors::projects::fedora {
  ocf_mirrors::qfm {
    'epel':
      remote_host => 'rsync://dl.fedoraproject.org',
      cron_hour   => '0/6',
      cron_minute => '10';
  }
}