# munin node config
class ocf::munin::node {
  package {
    ['munin-node', 'munin-plugins-core', 'munin-plugins-extra',
    'munin-libvirt-plugins']:;
  }

  service { 'munin-node':
    require => Package['munin-node'];
  }

  file { '/etc/munin/munin-node.conf':
    source  => 'puppet:///modules/ocf/munin/munin-node.conf',
    mode    => '0644',
    notify  => Service['munin-node'],
    require => Package['munin-node'];
  }

  file { '/etc/munin/plugin-conf.d/ocf-plugin-conf':
    content => template('ocf/munin/ocf-plugin-conf.erb'),
    mode    => '0644',
    notify  => Service['munin-node'],
    require => Package['munin-node'];
  }
}
