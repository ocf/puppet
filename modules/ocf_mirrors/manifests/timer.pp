define ocf_mirrors::timer(
  $minute = '*',
  $hour = '*',
  $day = '*',
  $month = '*',
  $year = '*',
  $exec_user = 'mirrors',
  $exec_start = '',
  $environments = {},
) {
  # Any meaningful second precision requires AccuracySec to be set
  $on_calendar = "${year}-${month}-${day} ${hour}:${minute}:00"

  ocf::systemd::timer { $title:
    service_content => template('ocf_mirrors/systemd/sync.service.erb'),
    timer_content   => template('ocf_mirrors/systemd/sync.timer.erb'),
  }

  # Ensure there is no duplicate cron job
  cron { $title:
    ensure => absent,
    user   => $exec_user,
  }
}
