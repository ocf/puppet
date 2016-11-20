class ocf::motd($nfs_motd = false) {
  if $nfs_motd {
    file { '/etc/motd':
      ensure => link,
      target => '/home/s/st/staff/motd/motd',
    }
  } else {
    $is_virtual = str2bool($::is_virtual)

    file { '/etc/motd':
      content => template('ocf/motd.erb'),
    }
  }
}
