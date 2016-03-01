class ocf::motd {
  file { '/etc/motd':
    ensure => link,
    target => '/home/s/st/staff/motd/motd',
  }
}
