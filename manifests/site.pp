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

### Generic nodes ###

node base {
  class { 'ocf::common::groups': stage => first }
  class { 'ocf::common::puppet': stage => first }
  class { 'ocf::common::rootpw': stage => first }
  case $::hostname {
    sandstorm: { }
    default:   { include ocf::common::ntp }
  }
  case $::hostname {
    sandstorm: { }
    default:   { include ocf::common::postfix }
  }
  include ocf::common::smart
}

node server inherits base {
  case $::hostname {
    death:     { class { 'ocf::common::apt': stage => first, nonfree => true } }
    spy:       { }
    default:   { class { 'ocf::common::apt': stage => first } }
  }
  include ocf::common::kerberos
  include ocf::common::ldap
  include ocf::common::packages
  case $::hostname {
    blight:        { class { 'ocf::common::pam': login => 'ocfstaff' } }
    coupdetat:     { class { 'ocf::common::pam': login => [ 'decal', 'ocfstaff' ], sudo => 'libvirt' } }
    diplomat, spy: { class { 'ocf::common::pam': login => 'ocfstaff' } }
    printhost:     { class { 'ocf::common::pam': login => 'printing', sudo => 'printing' } }
    default:       { include ocf::common::pam }
  }
  case $::hostname {
    coupdetat: { }
    default:   { include ocf::common::ssh }
  }
  case $::hostname {
    diplomat, spy: { }
    default:       { include ocf::common::zabbix }
  }
}

node desktop inherits base {
  class { 'ocf::common::apt': stage => first, nonfree => true, desktop => true }
  class { 'ocf::common::pam': login => 'ocf' }
  include ocf::common::acct
  include ocf::common::crondeny
  include ocf::common::cups
  include ocf::common::kerberos
  include ocf::common::ldap
  include ocf::common::networking
  include ocf::desktop::iceweasel
  include ocf::desktop::limits
  include ocf::desktop::packages
  include ocf::desktop::pulse
  include ocf::desktop::sshfs
  include ocf::desktop::suspend
  include ocf::desktop::tmpfs
  include ocf::desktop::xsession
}

### Managed nodes ###

# Puppet master
node lightning, puppet inherits server {
  class { 'ocf::common::networking': octet => 210 }
  include ocf::local::lightning
}

# Server room
node blight inherits server {
  class {'ocf::common::networking': octet => 236 }
  include ocf::local::blight
}
node coupdetat inherits server {
  class { 'ocf::common::networking': hosts => false, resolv => false, octet => 253 }
  include ocf::local::coupdetat
}
node death inherits server {
  class { 'ocf::common::networking': octet => 205 }
  include ocf::local::death
}
node fallout inherits server {
  class { 'ocf::common::networking': interfaces => false }
  include ocf::local::fallout
}
node maelstrom inherits server {
  class { 'ocf::common::networking': octet => 150 }
  include ocf::local::maelstrom
}
node pollution inherits server {
  class { 'ocf::common::networking': octet => 198 }
  include ocf::local::pollution
}
node printhost inherits server {
  class { 'ocf::common::networking': octet => 245 }
  include ocf::local::printhost
}
node sandstorm inherits server {
  class { 'ocf::common::networking': octet => 218 }
  #include ocf::local::sandstorm
}
node surge inherits server {
  class { 'ocf::common::networking': octet => 207 }
  include ocf::local::surge
}
node typhoon inherits server {
  class {'ocf::common::networking': octet => 214 }
  #include ocf::local::typhoon
}

# Lab
node avalanche, bigbang, cyclone, destruction, eruption, fallingrocks, hurricane, b1, b2, b3 inherits desktop {
}
node diplomat, spy inherits server {
  include ocf::common::cups
  #include ocf::desktop::suspend
  include ocf::desktop::tmpfs
  #include ocf::local::spy
}
