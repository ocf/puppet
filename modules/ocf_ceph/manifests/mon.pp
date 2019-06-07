# Ceph monitor + manager + metadata server configuration
# To bootstap, run puppet once, then run
# sudo -u ceph ceph-mon --mkfs -i $hostname --keyring /var/lib/ceph/mon-bootstrap-keyring
# Then run puppet again

class ocf_ceph::mon {
  require ocf_ceph
  require ocf_ceph::admin

  $mon_key = lookup('ceph::mon_key')

  $mgr_perms = "mon 'allow profile mgr' osd 'allow *' mds 'allow *'"
  $mgr_keyring_file = "/var/lib/ceph/mgr/ceph-${::hostname}/keyring"

  $mds_perms = "mon 'allow profile mds' osd 'allow *' mds 'allow *'"
  $mds_keyring_file = "/var/lib/ceph/mds/ceph-${::hostname}/keyring"

  file { ['/var/lib/ceph/mon',
          '/var/lib/ceph/mgr',
          '/var/lib/ceph/mds',
          "/var/lib/ceph/mon/ceph-${::hostname}",
          "/var/lib/ceph/mgr/ceph-${::hostname}",
          "/var/lib/ceph/mds/ceph-${::hostname}"]:
      ensure => directory,
      owner  => 'ceph',
      group  => 'ceph',
  }

  exec { "make-mgr-key-${::hostname}":
    command => "ceph auth add mgr.${::hostname} ${mgr_perms}",
    unless  => "ceph auth get mgr.${::hostname}",
  } ->

  exec { "export-mgr-key-${::hostname}":
    command => "ceph auth export mgr.${::hostname} -o ${mgr_keyring_file}",
    creates => $mgr_keyring_file,
  }

  exec { "make-mds-key-${::hostname}":
    command => "ceph auth add mds.${::hostname} ${mds_perms}",
    unless  => "ceph auth get mds.${::hostname}",
  } ->

  exec { "export-mds-key-${::hostname}":
    command => "ceph auth export mds.${::hostname} -o ${mds_keyring_file}",
    creates => $mds_keyring_file,
  }

  file {
    '/var/lib/ceph/mon-bootstrap-keyring':
      owner     => 'ceph',
      group     => 'ceph',
      show_diff => false,
      content   => template('ocf_ceph/mon-keyring.erb'),
  }

  service { ["ceph-mon@${::hostname}", "ceph-mgr@${::hostname}", "ceph-mds@${::hostname}"]:
    ensure  => running,
    require => Package['ceph'],
    enable  => true,
  }
}
