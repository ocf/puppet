class ocf {
  include ocf::apt
  include ocf::auth
  include ocf::autologout
  include ocf::etc
  include ocf::firewall
  include ocf::groups
  include ocf::kerberos
  include ocf::ldap
  include ocf::locale
  include ocf::logging
  include ocf::motd
  include ocf::munin::node
  include ocf::networking
  include ocf::packages
  include ocf::puppet
  include ocf::rootpw
  include ocf::serial_getty
  include ocf::systemd
  include ocf::utils
  include ocf::walldeny

  if $::lsbdistid != 'Raspbian' {
    include ocf::nodeexporter
  }
}
