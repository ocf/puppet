class ocf_desktop ($staff = false) {
  class { 'ocf::apt::i386':
    stage => first,
  }

  include ocf::acct
  include ocf::packages::cups
  include ocf::packages::chrome

  include crondeny
  include defaults
  include drivers
  include grub
  include iceweasel
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
