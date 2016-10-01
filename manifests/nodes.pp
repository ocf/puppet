node default {
  class { 'ocf::apt': stage => first }
  class { 'ocf::groups': stage => first }
  class { 'ocf::puppet': stage => first }
  class { 'ocf::rootpw': stage => first }

  include ocf

  case $::hostname {
    anthrax, dev-anthrax: {}
    default: { include ocf::packages::postfix }
  }

  if !$::skip_networking {
    $bridge = $hostname ? {
      /(hal|pandemic|jaws|raptors)/ => true,
      default => false,
    }
    class { 'ocf::networking':
      bridge => $bridge,
    }
  }

  case $type {
    'server': {
      if $owner == undef {
        case $::hostname {
          tsunami:    { class { 'ocf::auth': glogin => [ ['ocf', 'ALL'], ['sorry', 'ALL'] ] } }
          werewolves: { class { 'ocf::auth': glogin => [ ['ocfdev', 'ALL'] ] } }
          default:    { class { 'ocf::auth': ulogin => [], glogin => [], usudo => [], gsudo => [] } }
        }
      } else { # grant login and sudo to owner
        class { 'ocf::auth': ulogin => [[$owner, 'ALL']], usudo => [$owner], nopasswd => true }
      }
    }

    'desktop': {
      $glogin = $::staff_only ? {
        true    => [ ['ocfstaff', 'ALL'] ],
        default => [ ['ocf', 'LOCAL'] ]
      }

      class { 'ocf::auth':
        glogin => $glogin,
        gsudo  => ['ocfstaff'];
      }

      class { 'ocf_desktop': staff => $::staff_only }
    }
  }
}
