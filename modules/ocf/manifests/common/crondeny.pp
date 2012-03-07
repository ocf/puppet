class ocf::common::crondeny {

  # disable cron and at for all users except root
  file {
    '/etc/cron.allow':
      content => 'root';
    '/etc/at.allow':
      content => 'root';
  }

}
