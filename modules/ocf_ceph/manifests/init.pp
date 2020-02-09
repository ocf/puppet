# Base class for ceph

class ocf_ceph {
  require ocf::packages::ceph

  $ceph_mons_list = lookup('ceph::mons')
  $ceph_mon_ip_str = $ceph_mons_list.map
    |$node| { ldap_attr($node, 'ipHostNumber') }.join(',')
  $ceph_mon_ips = $ceph_mons_list.map
    |$node| { [$node, ldap_attr($node, 'ipHostNumber')] }

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
