class ocf::motd {
  $motd_from_nfs = str2bool($::ocf_nfs) and !hiera('staff_only')
  $owner = hiera('owner', undef)

  if $motd_from_nfs {
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
