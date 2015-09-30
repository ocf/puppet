class ocf {
  include ocf::autologout
  include ocf::kerberos
  include ocf::ldap
  include ocf::locale
  include ocf::munin::node
  include ocf::packages
  include ocf::utils

  if $::blockdevice_sda_vendor == 'LSI' and !str2bool($::is_virtual) {
    include ocf::megacli
  }
  if !str2bool($::is_virtual) {
    include ocf::mdraid
  }
}
