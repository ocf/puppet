# Override something set in a service file.
# This is a nicer way to override distro defaults than replacing the entire file.
# An example override file looks like:
#
#     [Service]
#     ; have to make it "empty" first to unset the old one
#     ExecStart=
#     ExecStart=/path/to/my/thing
define ocf::systemd::override(
    $unit,
    $ensure = present,
    $source = undef,
    $content = undef,
) {
  ensure_resource('file', "/etc/systemd/system/${unit}.d", {
    ensure => directory,
  })

  file { "/etc/systemd/system/${unit}.d/${title}.conf":
    ensure  => $ensure,
    source  => $source,
    content => $content,
    notify  => Exec['systemd-reload'],
    require => Package['systemd-sysv'],
  }

  if $unit =~ /(.*)\.service$/ {
    ensure_resource('service', $1)

    File["/etc/systemd/system/${unit}.d/${title}.conf"] ~> Service[$1]
    Exec['systemd-reload'] -> Service[$1]
  }
}
