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
    $source = undef,
    $content = undef,
) {
  ensure_resource('file', "/etc/systemd/system/${unit}.d", {
    ensure => directory,
  })

  file { "/etc/systemd/system/${unit}.d/${title}.conf":
    source  => $source,
    content => $content,
    notify  => Exec['systemd-reload'],
    require => Package['systemd-sysv'],
  }
}
