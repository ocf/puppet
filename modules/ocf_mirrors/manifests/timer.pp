define ocf_mirrors::timer(
  $minute = '*',
  $hour = '*',
  $day = '*',
  $month = '*',
  $year = '*',
  $type = 'sync',
  $exec_user = 'mirrors',
  $exec_start = '',
  $environments = {},
) {
  # Any meaningful second precision requires AccuracySec to be set
  $on_calendar = "${year}-${month}-${day} ${hour}:${minute}:00"

  if !($type in ['sync', 'monitor']) {
    fail('Type parameter of ocf_mirrors:timer must be either sync or monitor')
  }

  if $type == 'sync' {
    $service_content = template('ocf_mirrors/systemd/sync.service.erb')
  } else {
    $service_content = template('ocf_mirrors/systemd/monitor.service.erb')
  }

  ocf::systemd::timer { $title:
    service_content => $service_content,
    timer_content   => template('ocf_mirrors/systemd/all.timer.erb'),
  }

  # Ensure there is no duplicate cron job
  cron { $title:
    ensure => absent,
    user   => $exec_user,
  }
}
