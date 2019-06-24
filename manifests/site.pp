### global settings ###

# backup existing files to puppetmaster
filebucket { 'main':; }

# create first stage to run before everything else
stage { 'first': before => Stage['main'] }

### global defaults ###

# We almost always intend to create system users/groups
User { system => true, groups => ['sys'] }
Group { system => true }

# default path for executions
Exec { path => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin' }

# default file permissions, backup existing files to puppetmaster
File { mode => '0644', owner => root, group => root, backup => main }

# add managed filesystems to fstab by default
Mount { ensure => defined }

# use init script restart and status commands
Service { hasrestart => true, hasstatus => true }

Vcsrepo { require => Package['git'] }

Apache::Vhost { serveradmin => 'help@ocf.berkeley.edu' }

# Listen on IPv6 addresses by default for nginx (along with IPv4)
Nginx::Resource::Server {
  ipv6_enable         => true,
  ipv6_listen_options => '',
}

# By default, the cron type won't reset attributes if you don't specify them.
# (e.g. if you only set "minute => '0'", it won't reset hour to '*')
# This is bad behavior because the resource is only partially managed by Puppet.
# Change the defaults to make the cron type behave reasonably in our manifests.
#
# Also set the PATH environment variable to be the same as in /etc/crontab.
# The default PATH is only /usr/bin:/bin, which lacks a lot of commands.
Cron {
  special => 'absent',
  minute => '*',
  hour => '*',
  weekday => '*',
  month => '*',
  monthday => '*',
  environment => 'PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/opt/puppetlabs/bin'
}

Firewall_multi {
  require => Class['ocf::firewall::pre'],
  before  => Class['ocf::firewall::post'],
}

Ocf::Firewall::Firewall46 {
  require => Class['ocf::firewall::pre'],
  before  => Class['ocf::firewall::post'],
}
