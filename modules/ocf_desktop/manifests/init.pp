class ocf_desktop ($staff = false) {
  include ocf::acct
  include ocf::packages::chrome
  include ocf::packages::cups
  include ocf::packages::firefox

  include ocf_desktop::crondeny
  include ocf_desktop::defaults
  include ocf_desktop::drivers
  include ocf_desktop::grub
  include ocf_desktop::modprobe
  include ocf_desktop::packages
  include ocf_desktop::pulse
  include ocf_desktop::sshfs
  include ocf_desktop::stats
  include ocf_desktop::steam
  include ocf_desktop::suspend
  include ocf_desktop::tmpfs
  include ocf_desktop::udev
  include ocf_desktop::wireshark

  class { 'ocf_desktop::xsession': staff => $staff }
}
