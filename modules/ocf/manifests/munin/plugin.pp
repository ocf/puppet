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
define ocf::munin::plugin($source, $user = undef) {
  $file_defaults = {
    notify  => Service['munin-node'],
    require => Package['munin-node'],
  }

  file {
    default:
      * => $file_defaults;

    "/etc/munin/plugins/${title}":
      source  => $source,
      mode    => '0755',
  }

  if $user != undef {
    file { "/etc/munin/plugin-conf.d/plugin-${title}":
      ensure  => present,
      content => "[${title}]\nuser ${user}\n",
    }
  } else {
    file { "/etc/munin/plugin-conf.d/plugin-${title}":
      ensure => absent,
    }
  }
}
