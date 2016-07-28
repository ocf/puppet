### global settings ###

# backup existing files to puppetmaster
filebucket { 'main':; }

# create first stage to run before everything else
stage { 'first': before => Stage['main']; }

### global defaults ###

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

# Cron type won't reset attributes if you don't specify them.
# (e.g. if you only set "minute => '0'", it won't reset hour to '*')
# This is bad behavior because the resource is only partially managed by Puppet.
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
    environment => 'PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin'
}

$desktop_homepage = 'https://www.ocf.berkeley.edu/about/lab/open-source'
