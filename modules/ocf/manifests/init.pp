class ocf {
  include ocf::autologout
  include ocf::kerberos
  include ocf::ldap
  include ocf::locale
  include ocf::motd
  include ocf::munin::node
  include ocf::packages
  include ocf::staff_users
  include ocf::systemd
  include ocf::utils

  unless str2bool($::is_virtual) {
    include ocf::fstrim
    include ocf::mdraid
  }
}
