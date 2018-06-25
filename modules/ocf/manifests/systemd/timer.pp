# Creates two systemd units: a timer and service bearing the same
# name, whereby the service will be activated once the timer elapses.
define ocf::systemd::timer(
  $timer_content = undef,
  $service_content = undef,
  $timer_source = undef,
  $service_source = undef,
  $ensure = 'running',
  $enable = true,
) {
  # ocf::systemd::service will handle multiple timer sources
  if $service_content and $service_source {
    fail('You may not supply both content and source parameters to ocf::systemd::timer')
  }
  elsif $service_content == undef and $service_source == undef {
    fail('You must supply either the content or source parameter to ocf::systemd::timer')
  }
  elsif $timer_content and $timer_source {
    fail('You may not supply both content and source parameters to ocf::systemd::timer')
  }
  elsif $timer_content == undef and $timer_source == undef {
    fail('You must supply either the content or source parameter to ocf::systemd::timer')
  }

  file {
    "/etc/systemd/system/${title}.timer":
      source  => $timer_source,
      content => $timer_content,
      notify  => Exec['systemd-reload'],
      require => Package['systemd-sysv'];

    "/etc/systemd/system/${title}.service":
      source  => $service_source,
      content => $service_content,
      notify  => Exec['systemd-reload'],
      require => [
        Package['systemd-sysv'],
        File["/etc/systemd/system/${title}.timer"],
      ];
  } ~>
  service { "${title}.timer":
    ensure   => $ensure,
    enable   => $enable,
    provider => systemd,
    require  => [
      Package['systemd-sysv'],
      File["/etc/systemd/system/${title}.timer"],
      Exec['systemd-reload'],
    ],
  }
}
