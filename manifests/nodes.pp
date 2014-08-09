node default {

  class { 'common::groups': stage => first }
  class { 'common::puppet': stage => first }
  class { 'common::rootpw': stage => first }
  case $::hostname {
    anthrax, sandstorm, typhoon: { }
    default:   { include common::postfix }
  }
  case $::hostname {
    hal, pandemic, jaws: { class { 'common::ntp': physical => true } }
    default:             { include common::ntp }
  }
  case $::hostname {
    dementors:   { class { 'common::munin': master => true } }
    default:     { include common::munin }
  }
  include common::autologout
  include common::git
  include common::kerberos
  include common::ldap
  include common::locale
  include common::memtest
  include common::smart
  include common::utils
  include common::zabbix
  include common::zsh
  if $::macAddress {
      include networking
  } else {
    case $::hostname {
      hal, pandemic, jaws: {
        $bridge = true
        $vlan   = false
      }
      default: {
        $bridge = false
        $vlan   = false
      }
    }
    class { 'networking':
      ipaddress   => $::ipHostNumber,
      netmask     => '255.255.255.0',
      gateway     => '169.229.10.1',
      bridge      => $bridge,
      vlan        => $vlan,
      domain      => 'ocf.berkeley.edu',
      nameservers => ['169.229.10.22', '128.32.206.12', '128.32.136.9'],
    }
  }

  if $type == 'server' {
    case $::hostname {
      death:     { class { 'common::apt': stage => first, nonfree => true } }
      default:   { class { 'common::apt': stage => first } }
    }
    case $::hostname {
      supernova: { class { 'common::packages': extra => true, login => true } }
      tsunami:   { class { 'common::packages': extra => true, login => true } }
      default:   { class { 'common::packages': } }
    }

    if $owner == undef {
      case $::hostname {
        locusts:   { class { 'common::auth': ulogin => [ ['NuclearPoweredKimJongIl', 'ALL' ] ] } }
        pollution: { class { 'common::auth': glogin => [ ['approve', 'ALL'] ], gsudo => [ 'ocfstaff' ] } }
        supernova: { class { 'common::auth': glogin => [ ['approve', 'ALL'] ] } }
        tornado:   { class { 'common::auth': ulogin => [ ['kiosk', 'LOCAL'] ] } }
        tsunami:   { class { 'common::auth': glogin => [ ['ocf', 'ALL'], ['sorry', 'ALL'] ] } }
        default:   { class { 'common::auth': ulogin => [], glogin => [], usudo => [], gsudo => [] } }
      }
    } else { # grant login and sudo to owner
      class { 'common::auth': ulogin => [[$owner, 'ALL']], usudo => [$owner] }
    }
    include common::ssh
  }

  if $type == 'desktop' {
    class { 'common::apt':  stage => first, nonfree => true, desktop => true }
    case $::hostname {
      eruption:  { class { 'common::auth': glogin => [ ['approve', 'LOCAL'] ] } }
      default:   { class { 'common::auth': glogin => [ ['ocf', 'LOCAL'] ] } }
    }
    include common::acct
    include common::cups
    include desktop::crondeny
    include desktop::defaults
    include desktop::grub
    include desktop::iceweasel
    include desktop::chrome
    include desktop::modprobe
    include desktop::packages
    include desktop::pam
    include desktop::pulse
    include desktop::sshfs
    include desktop::stats
    include desktop::suspend
    if $::hostname != 'eruption' {
      include desktop::tmpfs
    }
    include desktop::xsession
  }

}
