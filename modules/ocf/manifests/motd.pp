class ocf::motd {
  $is_virtual = str2bool($::is_virtual)

  if tagged('ocf_ssh') or tagged('ocf_apphost') {
    file { '/etc/motd':
      ensure => link,
      target => '/home/s/st/staff/motd/motd',
    }
  } else {
    file { '/etc/motd':
      content => template('ocf/motd.erb'),
    }
  }
}
