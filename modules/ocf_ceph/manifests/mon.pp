# Ceph monitor + manager + metadata server configuration
# For now, each monitor (mon) is also a manager (mgr) and a metadata server (mds)

class ocf_ceph::mon {
  require ocf_ceph
  require ocf_ceph::admin

  $mon_key = lookup('ceph::mon_key')
  $admin_key = lookup('ceph::admin_key')
  $bootstrap_osd_key = lookup('ceph::bootstrap_osd_key')

  file { [
      '/var/lib/ceph/mon',
      '/var/lib/ceph/mgr',
      '/var/lib/ceph/mds',
      "/var/lib/ceph/mon/ceph-${::hostname}",
      "/var/lib/ceph/mgr/ceph-${::hostname}",
      "/var/lib/ceph/mds/ceph-${::hostname}",
    ]:
      ensure => directory,
      owner  => 'ceph',
      group  => 'ceph',
  }

  # Allow Ceph monitor communications
  ocf::firewall::firewall46 {
    '101 allow ceph monitors':
      opts => {
        chain  => 'PUPPET-INPUT',
        proto  => 'tcp',
        dport  => 3300,
        action => 'accept',
      };
  }

  # Creates a per-host keyring from the bootstrap keyring
  exec { "bootstrap-mon-${::hostname}":
    user    => 'ceph',
    command => "ceph-mon --mkfs -i ${::hostname} --keyring /var/lib/ceph/mon-bootstrap-keyring",
    creates => "/var/lib/ceph/mon/ceph-${::hostname}/keyring",
    require => [
      File["/var/lib/ceph/mon/ceph-${::hostname}"],
      File['/var/lib/ceph/mon-bootstrap-keyring'],
    ],
  }

  # mgr perms from https://docs.ceph.com/docs/nautilus/mgr/administrator/
  $mgr_perms = "mon 'allow profile mgr' osd 'allow *' mds 'allow *'"
  $mgr_keyring_file = "/var/lib/ceph/mgr/ceph-${::hostname}/keyring"

  # Creates the key mgr.$name and writes it to the needed location
  exec { "make-mgr-key-${::hostname}":
    command => "ceph auth add mgr.${::hostname} ${mgr_perms}",
    unless  => "ceph auth get mgr.${::hostname}",
  } ->
  exec { "export-mgr-key-${::hostname}":
    command => "ceph auth export mgr.${::hostname} -o ${mgr_keyring_file}",
    creates => $mgr_keyring_file,
  }

  # mds perms from https://docs.ceph.com/docs/nautilus/cephfs/add-remove-mds/
  $mds_perms = "mon 'allow profile mds' osd 'allow *' mds 'allow *'"
  $mds_keyring_file = "/var/lib/ceph/mds/ceph-${::hostname}/keyring"

  # Creates the key mds.$name and writes it to a file
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

  service { [
      "ceph-mon@${::hostname}",
      "ceph-mgr@${::hostname}",
      "ceph-mds@${::hostname}",
    ]:
      ensure  => running,
      require => Package['ceph'],
      enable  => true,
  }
}
