### Generic nodes ###

node base {
  class { 'ocf::common::groups': stage => first }
  class { 'ocf::common::puppet': stage => first }
  class { 'ocf::common::rootpw': stage => first }
  include ocf::common::ntp
  include ocf::common::postfix
  include ocf::common::smart
}

node server inherits base {
  case $hostname {
    death:   { class { 'ocf::common::apt': stage => first, nonfree => true } }
    default: { class { 'ocf::common::apt': stage => first } }
  }
  include ocf::common::kerberos
  include ocf::common::ldap
  include ocf::common::packages
  case $hostname {
    printhost: { class { 'ocf::common::pam': login => 'printing', sudo => 'printing' } }
    coupdetat: { class { 'ocf::common::pam': login => [ 'decal', 'ocfstaff' ], sudo => 'libvirt' } }
    default:   { include ocf::common::pam }
  }
  include ocf::common::ssh
  include ocf::common::zabbix
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

# Servers
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
node pollution inherits server {
  class { 'ocf::common::networking': octet => 198 }
  include ocf::local::pollution
}
node printhost inherits server {
  class { 'ocf::common::networking': octet => 245 }
  include ocf::local::printhost
}
node surge inherits server {
  class { 'ocf::common::networking': octet => 207 }
  include ocf::local::surge
}

# Desktops
node avalanche, bigbang, cyclone, destruction, eruption, fallingrocks, hurricane, plague, b1, b2, b3 inherits desktop {
}
node spy inherits server {
  include ocf::local::spy
}
