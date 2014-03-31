class desktop::crondeny {
  file {
    '/etc/cron.allow':
      content => "root\nocfstats\n";
    '/etc/at.allow':
      content => "root\n";
  }
}
