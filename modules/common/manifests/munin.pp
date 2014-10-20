# munin node config
class common::munin {
  package {
    ['munin-node', 'munin-plugins-core', 'munin-plugins-extra',
    'munin-libvirt-plugins']:;
  }

  service { 'munin-node':
    require => Package['munin-node'];
  }

  file { '/etc/munin/munin-node.conf':
    source  => 'puppet:///modules/common/munin/munin-node.conf',
    mode    => '0644',
    notify  => Service['munin-node'],
    require => Package['munin-node'];
  }
}
