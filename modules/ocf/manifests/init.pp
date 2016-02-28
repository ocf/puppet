class ocf {
  include ocf::autologout
  include ocf::kerberos
  include ocf::ldap
  include ocf::locale
  include ocf::munin::node
  include ocf::packages
  include ocf::staff_users
  include ocf::utils

  if !str2bool($::is_virtual) {
    include ocf::fstrim
    include ocf::mdraid
  }
}
