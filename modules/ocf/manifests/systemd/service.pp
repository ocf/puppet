define ocf::systemd::service(
  $source = undef,
  $content = undef,
  $ensure = 'running',
  $enable = true,
) {
  if $content and $source {
    fail('You may not supply both content and source parameters to ocf::systemd::service')
  }
  elsif $content == undef and $source == undef {
    fail('You must supply either the content or source parameter to ocf::systemd::service')
  }

  file { "/etc/systemd/system/${title}.service":
    source  => $source,
    content => $content,
    notify  => Exec['systemd-reload'],
    require => Package['systemd-sysv'],
  } ~>
  service { $title:
    ensure    => $ensure,
    enable    => $enable,
    provider  => systemd,
    require   => [
      Package['systemd-sysv'],
      File["/etc/systemd/system/${title}.service"],
      Exec['systemd-reload'],
    ],
  }
}
