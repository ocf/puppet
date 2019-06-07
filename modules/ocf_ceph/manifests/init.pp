# Base class for ceph

class ocf_ceph {
  include ocf::packages::ceph

  $ceph_mons_list = lookup('ceph::mons')
  $ceph_mons = $ceph_mons_list.join(',')
  $ceph_mon_ips = $ceph_mons_list.map
    |$node| { ldap_attr($node, 'ipHostNumber') }.join(',')

  $ip_addr = $::ipaddress

  file { '/etc/ceph/ceph.conf':
    content => template('ocf_ceph/ceph.conf.erb'),
    require => Package['ceph'],
  }

  file { '/var/lib/ceph':
    ensure => directory,
    owner  => 'ceph',
    group  => 'ceph',
    mode   => '0750',
  }
}
