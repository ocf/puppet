### global settings ###

# backup existing files to puppetmaster
# path must be explicitly undefined, see puppet bug #5362
filebucket { 'main': path => false, }

# create first stage to run before everything else
stage { 'first': before => Stage['main'], }

### global defaults ###

# default path for executions
Exec { path => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin', }

# default file permissions, follow symlinks when serving files, backup existing files to puppetmaster
File { mode => 0644, owner => root, group => root, links => follow, backup => main, }

# add managed filesystems to fstab by default
Mount { ensure => defined, }

# use aptitude for package installation
Package { provider => aptitude, }

### node definitions ###

import 'nodes'
