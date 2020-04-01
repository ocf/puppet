class ocf_ceph::rgw {
  require ocf_ceph
  require ocf_ceph::admin

  class { 'ocf_lb':
    vip_names                => ['ceph'],
    keepalived_secret_lookup => 'ceph::keepalived::secret',
    vrid                     => 52,
  }

  file { [
      '/var/lib/ceph/radosgw',
      "/var/lib/ceph/radosgw/ceph-${::hostname}",
    ]:
    ensure => directory,
    owner  => 'ceph',
    group  => 'ceph',
  }

  # rgw perms from https://docs.ceph.com/docs/nautilus/rados/configuration/auth-config-ref/#daemon-keyrings
  $rgw_perms = "mon 'allow rwx' osd 'allow rwx'"
  $rgw_keyring_file = "/var/lib/ceph/radosgw/ceph-${::hostname}/keyring"

  # Creates the key mgr.$name and writes it to the needed location
  exec { "make-rgw-client-key-${::hostname}":
    command => "ceph auth add client.${::hostname} ${rgw_perms}",
    unless  => "ceph auth get client.${::hostname}",
    require => File["/var/lib/ceph/radosgw/ceph-${::hostname}"],
  } ->
  exec { "export-rgw-client-key-${::hostname}":
    command => "ceph auth export client.${::hostname} -o ${rgw_keyring_file}",
    creates => $rgw_keyring_file,
  }

  ocf::repackage { 'radosgw':
    backport_on => ['buster'],
  } ->
  service { "ceph-radosgw@${::hostname}":
    ensure    => running,
    require   => Package['ceph'],
    subscribe => [
      File['/etc/ceph/ceph.conf'],
      Ocf::Ssl::Bundle['ceph.ocf.berkeley.edu'],
      Exec["export-rgw-client-key-${::hostname}"],
    ],
    enable    => true,
  }
}
