# Munin plugin resource
#
# Can be used to produce custom graphs in Munin. The config should be applied
# at the *node* level, not on the master.
#
# Example usage:
# ocf::munin::plugin { 'csgo':
#   source => 'puppet:///modules/ocf_srcds/munin';
# }
#
# See for instructions on writing new plugins:
# http://munin-monitoring.org/wiki/HowToWritePlugins
define ocf::munin::plugin($source) {
  file { "/etc/munin/plugins/${title}":
    source  => $source,
    owner   => root,
    group   => root,
    mode    => '0755',
    notify  => Service['munin-node'];
  }
}
