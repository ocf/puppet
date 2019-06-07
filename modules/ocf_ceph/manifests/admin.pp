# Ceph admin key class, allows ceph to be used from the command line

class ocf_ceph::admin {
  include ocf_ceph

  $admin_key = lookup('ceph::admin_key')

  file { '/etc/ceph/ceph.client.admin.keyring':
    content   => template('ocf_ceph/admin-keyring.erb'),
    require   => Package['ceph'],
    owner     => 'ceph',
    group     => 'ceph',
    mode      => '0640',
    show_diff => false,
  }
}
