node default {
  class { 'common::groups': stage => first }
  class { 'common::puppet': stage => first }
  class { 'common::rootpw': stage => first }

  case $::hostname {
    anthrax, sandstorm, typhoon: { }
    default:   { include common::postfix }
  }

  include common::ntp
  include common::munin
  include common::autologout
  include common::git
  include common::kerberos
  include common::ldap
  include common::locale
  include common::memtest
  include common::smart
  include common::utils
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

  case $type {
    'server': {
      class { 'common::apt': stage => first }

      case $::hostname {
        supernova: { class { 'common::packages': extra => true, login => true } }
        tsunami:   { class { 'common::packages': extra => true, login => true } }
        biohazard: { class { 'common::packages': extra => true, login => true } }
        default:   { class { 'common::packages': } }
      }

      if $owner == undef {
        case $::hostname {
          supernova: { class { 'common::auth': glogin => [ ['approve', 'ALL'] ] } }
          tsunami:   { class { 'common::auth': glogin => [ ['ocf', 'ALL'], ['sorry', 'ALL'] ] } }
          biohazard: { class { 'common::auth': glogin => [ ['ocfdev', 'ALL'] ] } }
          pollution: { class { 'common::auth': glogin => [ ['approve', 'ALL'] ], gsudo => ['ocfstaff'] } }
          default:   { class { 'common::auth': ulogin => [], glogin => [], usudo => [], gsudo => [] } }
        }
      } else { # grant login and sudo to owner
        class { 'common::auth': ulogin => [[$owner, 'ALL']], usudo => [$owner] }
      }

      include common::ssh
    }

    'desktop': {
      if $::staff_only {
        class { 'common::auth': glogin => [ ['approve', 'ALL'] ], gsudo => ['ocfstaff'] }
      } else {
        class { 'common::auth': glogin => [ ['ocf', 'LOCAL'] ], gsudo => ['ocfstaff'] }
      }

      class { 'desktop': staff => $::staff_only }
    }
  }
}
