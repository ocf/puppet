node default {
  class { 'ocf::groups': stage => first }
  class { 'ocf::puppet': stage => first }
  class { 'ocf::rootpw': stage => first }

  include ocf

  case $::hostname {
    anthrax, sandstorm: {}
    default:   { include ocf::packages::postfix }
  }

  if $::macAddress {
    # use DHCP
    include ocf::networking
  } else {
    case $::hostname {
      hal, pandemic, jaws: {
        $bridge = true
      }
      default: {
        $bridge = false
      }
    }
    if !$::skipNetworking {
      class { 'ocf::networking':
        ipaddress   => $::ipHostNumber,
        netmask     => '255.255.255.0',
        gateway     => '169.229.226.1',
        bridge      => $bridge,
        domain      => 'ocf.berkeley.edu',
        nameservers => ['169.229.226.22', '128.32.206.12', '128.32.136.9'],
      }
    }
  }

  case $type {
    'server': {
      class { 'ocf::apt': stage => first }

      if $owner == undef {
        case $::hostname {
          supernova: { class { 'ocf::auth': glogin => [ ['approve', 'ALL'] ] } }
          tsunami:   { class { 'ocf::auth': glogin => [ ['ocf', 'ALL'], ['sorry', 'ALL'] ] } }
          biohazard: { class { 'ocf::auth': glogin => [ ['ocfdev', 'ALL'] ] } }
          pollution: { class { 'ocf::auth': glogin => [ ['approve', 'ALL'] ], gsudo => ['ocfstaff'] } }
          default:   { class { 'ocf::auth': ulogin => [], glogin => [], usudo => [], gsudo => [] } }
        }
      } else { # grant login and sudo to owner
        class { 'ocf::auth': ulogin => [[$owner, 'ALL']], usudo => [$owner], nopasswd => true }
      }
    }

    'desktop': {
      $glogin = $::staff_only ? {
        true    => [ ['approve', 'ALL'] ],
        default => [ ['ocf', 'LOCAL'] ]
      }

      class { 'ocf::auth':
        glogin => $glogin,
        gsudo => ['ocfstaff'];
      }

      class { 'ocf_desktop': staff => $::staff_only }
    }
  }
}
