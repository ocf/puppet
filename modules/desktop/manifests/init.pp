class desktop ($staff = false) {
  class { 'common::apt': stage => first, desktop => true }
  include common::acct
  include common::cups

  include chrome
  include crondeny
  include defaults
  include grub
  include iceweasel
  include modprobe
  include packages
  include pam
  include pulse
  include sshfs
  include stats
  include suspend
  include xsession

  class { 'tmpfs': staff => $staff }
}
