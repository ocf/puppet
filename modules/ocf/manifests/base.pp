class ocf::base {
  include ocf::apt
  include ocf::auth
  include ocf::autologout
  include ocf::groups
  include ocf::kerberos
  include ocf::ldap
  include ocf::locale
  include ocf::motd
  include ocf::munin::node
  include ocf::networking
  include ocf::packages
  include ocf::puppet
  include ocf::rootpw
  include ocf::serial_getty
  include ocf::staff_users
  include ocf::systemd
  include ocf::utils
}
