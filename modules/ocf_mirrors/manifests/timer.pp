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

  if $::host_env == 'dev' {
    # Don't actually run the syncing commands when in dev since they will fill
    # up the entire disk, so just print out what script would have been run to
    # syslog
    $exec = "logger -t ${title}_systemd_service: Would have run '${exec_start}' if in prod"
  } else {
    $exec = $exec_start
  }

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
