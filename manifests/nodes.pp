node default {
  class { 'common::groups': stage => first }
  class { 'common::puppet': stage => first }
  class { 'common::rootpw': stage => first }

  case $::hostname {
    anthrax, sandstorm, typhoon: { }
    default:   { include common::postfix }
  }

  include common::autologout
  include common::git
  include common::kerberos
  include common::ldap
  include common::locale
  include common::memtest
  include common::munin
  include common::ntp
  include common::packages
  include common::ocflib
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
    if !$::skipNetworking {
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
  }

  case $type {
    'server': {
      class { 'common::apt': stage => first }

      if $owner == undef {
        case $::hostname {
          supernova: { class { 'common::auth': glogin => [ ['approve', 'ALL'] ] } }
          tsunami:   { class { 'common::auth': glogin => [ ['ocf', 'ALL'], ['sorry', 'ALL'] ] } }
          biohazard: { class { 'common::auth': glogin => [ ['ocfdev', 'ALL'] ] } }
          pollution: { class { 'common::auth': glogin => [ ['approve', 'ALL'] ], gsudo => ['ocfstaff'] } }
          default:   { class { 'common::auth': ulogin => [], glogin => [], usudo => [], gsudo => [] } }
        }
      } else { # grant login and sudo to owner
        class { 'common::auth': ulogin => [[$owner, 'ALL']], usudo => [$owner], nopasswd => true }
      }

      include common::ssh
    }

    'desktop': {
      $glogin = $::staff_only ? {
        true    => [ ['approve', 'ALL'] ],
        default => [ ['ocf', 'LOCAL'] ]
      }

      class { 'common::auth':
        glogin => $glogin,
        gsudo => ['ocfstaff'];
      }

      class { 'desktop': staff => $::staff_only }
    }
  }
}
