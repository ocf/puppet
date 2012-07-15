### global definitions ###

# backup existing files to puppetmaster
# path must be explicitly undefined, see puppet bug #5362
filebucket { 'main': path => false }
# create first stage to run before everything else
stage { 'first': before => Stage['main'] }

### global defaults ###

# default path for executions
Exec { path => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin' }
# default file permissions and backup existing files to puppetmaster
File { mode => 0644, owner => root, group => root, backup => main }
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
  if $::is_virtual {
    include ocf::common::kexec
  }
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
    death:   { class { 'ocf::common::apt': stage => first, nonfree => true } }
    default: { class { 'ocf::common::apt': stage => first } }
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
  include ocf::common::kexec
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

### managed nodes ###

# puppetmaster
node lightning, puppet inherits server {
  class { 'ocf::common::networking': octet => 210 }
  include ocf::local::lightning
}

# server room
node blight inherits server {
  class {'ocf::common::networking': octet => 236 }
  include ocf::local::blight
}
node conquest inherits server {
  class {'ocf::common::networking': octet => 248 }
  #include ocf::local::conquest
}
node coupdetat inherits server {
  class { 'ocf::common::networking': hosts => false, resolv => false, octet => 253 }
  include ocf::local::coupdetat
}
node death inherits server {
  class { 'ocf::common::networking': octet => 243 }
  include ocf::common::acct
  include ocf::local::death
}
node fallout inherits server {
  class { 'ocf::common::networking': interfaces => false }
  include ocf::local::fallout
}
node hal inherits server {
  class { 'ocf::common::networking': interfaces => false }
  include ocf::common::kexec
  include ocf::local::hal
}
node maelstrom inherits server {
  class { 'ocf::common::networking': octet => 150 }
  include ocf::local::maelstrom
}
node pandemic inherits server {
  class { 'ocf::common::networking': octet => 206 }
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
node typhoon inherits server {
  class {'ocf::common::networking': octet => 214 }
  #include ocf::local::typhoon
}
node war inherits server {
  class {'ocf::common::networking': octet => 244 }
  include ocf::local::war
}

# lab and lounge
node avalanche, bigbang, cyclone, destruction, eruption, fallingrocks, hurricane, b1, b2, b3 inherits desktop {
}
node diplomat, spy inherits server {
  include ocf::common::cups
  #include ocf::desktop::suspend
  include ocf::desktop::tmpfs
  #include ocf::local::spy
}
