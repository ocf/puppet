node default {

  class { 'ocf::common::groups': stage => first }
  class { 'ocf::common::puppet': stage => first }
  class { 'ocf::common::rootpw': stage => first }
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
  include ocf::common::zabbix
  if $::ipoctet != undef {
    case $::hostname {
      hal, fallingrocks, pandemic: {$bridge = true}
      default: {$bridge = false}
    }
    class { 'networking':
      ipaddress   => "169.229.172.$::ipoctet",
      netmask     => '255.255.255.192',
      gateway     => '169.229.172.65',
      bridge      => $bridge,
      domain      => 'ocf.berkeley.edu',
      nameservers => ['169.229.172.66', '128.32.206.12', '128.32.136.9'],
    }
  }
  else {
      include networking
  }

  if $type == 'server' {
    case $::hostname {
      death:     { class { 'ocf::common::apt': stage => first, nonfree => true } }
      default:   { class { 'ocf::common::apt': stage => first } }
    }
    case $::hostname {
      supernova: { class { 'ocf::common::packages': extra => true, login => true } }
      tsunami:   { class { 'ocf::common::packages': extra => true, login => true } }
      default:   { class { 'ocf::common::packages': } }
    }
    case $::hostname {
      flood:     { class { 'ocf::common::auth': usudo => 'nolm' } }
      printhost: { class { 'ocf::common::auth': login => 'approve', gsudo => 'ocfstaff' } }
      tsunami:   { class { 'ocf::common::auth': login => 'ocf' } }
      default:   { class { 'ocf::common::auth': } }
    }
    include ocf::common::ssh
  }

  if $type == 'desktop' {
    class { 'ocf::common::apt':  stage => first, nonfree => true, desktop => true }
    class { 'ocf::common::auth': login => 'ocf' }
    include ocf::common::acct
    include ocf::common::crondeny
    include ocf::common::cups
    include ocf::desktop::acroread
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

}
