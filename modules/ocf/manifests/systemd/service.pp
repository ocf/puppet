define ocf::systemd::service(
  $source = undef,
  $content = undef,
  $ensure = 'running',
  $enable = true,
) {
  file { "/etc/systemd/system/${title}.service":
    source  => $source,
    content => $content,
    notify  => Exec['systemd-reload'],
    require => Package['systemd-sysv'],
  }

  service { $title:
    ensure    => $ensure,
    enable    => $enable,
    provider  => systemd,
    subscribe => File["/etc/systemd/system/${title}.service"],
    require   => [
      Package['systemd-sysv'],
      File["/etc/systemd/system/${title}.service"],
      Exec['systemd-reload'],
    ],
  }
}
