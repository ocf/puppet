### Global definitions ###
# Store old config on puppetmaster
filebucket { 'main': path => false }
# Create first stage to run before everything else
stage { 'first': before => Stage['main'] }

### Global defaults ###
# Set path for executions
Exec { path => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin' }
# Set default file permissions and store old config on puppetmaster
File { mode => 0644, owner => root, group => root, backup => main }
# Add managed filesystems to fstab by default
Mount { ensure => defined }
# Use aptitude for package installation
Package { provider => aptitude }
# Use init scripts
Service { hasstatus => true, hasrestart => true }

### Nodes ###
import 'nodes.pp'
