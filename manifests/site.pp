### global definitions ###

# backup existing files to puppetmaster
# path must be explicitly undefined, see puppet bug #5362
filebucket { 'main': path => false }
# create first stage to run before everything else
stage { 'first': before => Stage['main'] }

### global defaults ###

# default path for executions
Exec { path => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin' }
# default file permissions, follow symlinks when serving files, backup existing files to puppetmaster
File { mode => 0644, owner => root, group => root, links => follow, backup => main }
# add managed filesystems to fstab by default
Mount { ensure => defined }
# use aptitude for package installation
Package { provider => aptitude }
# use init scripts
Service { hasstatus => true, hasrestart => true }

### generic nodes ###

node base {
  class { 'ocf::common::groups': stage => first }
  class { 'ocf::common::puppet': stage => first }
  class { 'ocf::common::rootpw': stage => first }
  if $::is_virtual == 'true' {
    include ocf::common::kexec
  }
  case $::hostname {
    hal, pandemic: { }
    default:       { include ocf::common::ntp }
  }
  case $::hostname {
    sandstorm: { }
    default:   { include ocf::common::postfix }
  }
  include ocf::common::autologout
  include ocf::common::kerberos
  include ocf::common::ldap
  include ocf::common::smart
}

node server inherits base {
  case $::hostname {
    death:     { class { 'ocf::common::apt': stage => first, nonfree => true } }
    diplomat:  { class { 'ocf::common::apt': stage => first, nonfree => true, kiosk => true } }
    default:   { class { 'ocf::common::apt': stage => first } }
  }
  case $::hostname {
    tsunami:   { class { 'ocf::common::packages': extra => true, login => true } }
    default:   { class { 'ocf::common::packages': } }
  }
  case $::hostname {
    coupdetat: { class { 'ocf::common::auth': login => 'decal',   gsudo  => 'libvirt' } }
    emp:       { class { 'ocf::common::auth': usudo => 'amloessb' } }
    flood:     { class { 'ocf::common::auth': usudo => 'nolm' } }
    printhost: { class { 'ocf::common::auth': login => 'approve', gsudo => 'ocfstaff' } }
    tsunami:   { class { 'ocf::common::auth': login => 'ocf' } }
    default:   { class { 'ocf::common::auth': } }
  }
  include ocf::common::ssh
  include ocf::common::zabbix
}

node desktop inherits base {
  class { 'ocf::common::apt':  stage => first, nonfree => true, desktop => true }
  class { 'ocf::common::auth': login => 'ocf' }
  include ocf::common::acct
  include ocf::common::crondeny
  include ocf::common::cups
  include ocf::common::kexec
  include ocf::common::networking
  include ocf::desktop::iceweasel
  include ocf::desktop::limits
  include ocf::desktop::lxpanel
  include ocf::desktop::numlockx
  include ocf::desktop::packages
  include ocf::desktop::pulse
  include ocf::desktop::sshfs
  include ocf::desktop::suspend
  include ocf::desktop::tmpfs
  include ocf::desktop::xsession
}

### managed nodes ###

# puppetmaster
node lightning, puppet inherits server {
  class { 'ocf::common::networking': octet => 210 }
  include ocf::local::lightning
}

# servers
node blight inherits server {
  class {'ocf::common::networking': octet => 236 }
  include ocf::local::blight
}
node conquest inherits server {
  class {'ocf::common::networking': octet => 248 }
  #include ocf::local::conquest
}
node coupdetat inherits server {
  class { 'ocf::common::networking': interfaces => false }
  #include ocf::local::coupdetat
}
node death inherits server {
  class { 'ocf::common::networking': octet => 243 }
  include ocf::common::acct
  include ocf::local::death
}
node emp inherits server {
  class { 'ocf::common::networking': octet => 194 }
}
node fallingrocks inherits server {
  class { 'ocf::common::networking': interfaces => false }
  class { 'ocf::services::kvm':      octet      => 79 }
  include ocf::common::kexec
}
node fallout inherits server {
  class { 'ocf::common::networking': octet => 196 }
  include ocf::local::fallout
}
node "fallout.lab" inherits server {
  class { 'ocf::common::networking': octet => 67 }
  include ocf::local::fallout2
}
node firestorm inherits server{
  class { 'ocf::common::networking': octet => 200 }
  include ocf::local::firestorm
}
node flood inherits server{
  class { 'ocf::common::networking': octet => 95 }
  #include ocf::local::flood
}
node hal inherits server {
  class { 'ocf::common::networking': interfaces => false }
  class { 'ocf::services::kvm':      octet      => 199 }
  include ocf::common::kexec
  #include ocf::local::hal
}
node mudslide inherits server {
  class { 'ocf::common::networking': octet => 203 }
  #include ocf::local::mudslide
}
node pandemic inherits server {
  class { 'ocf::common::networking': interfaces => false }
  class { 'ocf::services::kvm':      octet      => 206 }
  include ocf::common::kexec
  #include ocf::local::pandemic
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
  include ocf::common::acct
  #include ocf::local::sandstorm
}
node surge inherits server {
  class { 'ocf::common::networking': octet => 207 }
  include ocf::local::surge
}
node tsunami inherits server {
  class { 'ocf::common::networking': octet => 223 }
}
node typhoon inherits server {
  class { 'ocf::common::networking': octet => 214 }
  #include ocf::local::typhoon
}
node war inherits server {
  class { 'ocf::common::networking': octet => 244 }
  include ocf::local::war
}
node zombie inherits server {
  class { 'ocf::common::networking': octet => 229 }
  include ocf::local::maelstrom
}

# lab and lounge
node avalanche, bigbang, cyclone, debian, destruction, eruption, hurricane, b1, b2, b3, b4, 02 inherits desktop {
}
node diplomat, spy inherits server {
  include ocf::common::cups
  #include ocf::desktop::suspend
  include ocf::desktop::tmpfs
  #include ocf::local::spy
}
