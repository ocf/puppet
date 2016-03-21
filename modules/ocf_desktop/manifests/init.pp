class ocf_desktop ($staff = false) {
  include ocf::acct
  include ocf::packages::cups
  include ocf::packages::chrome

  include crondeny
  include defaults
  include drivers
  include firefox
  include grub
  include modprobe
  include packages
  include pulse
  include sshfs
  include stats
  include steam
  include suspend
  include tmpfs
  include wireshark

  class { 'xsession': staff => $staff }
}
