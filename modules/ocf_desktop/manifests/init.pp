class ocf_desktop {
  include ocf::acct
  include ocf::packages::brave
  include ocf::packages::chrome
  include ocf::packages::cups
  include ocf::packages::firefox
  include ocf::packages::pulse
  include ocf::packages::vscode

  include ocf_desktop::crondeny
  include ocf_desktop::defaults
  include ocf_desktop::drivers
  include ocf_desktop::firewall_output
  include ocf_desktop::grub
  include ocf_desktop::modprobe
  include ocf_desktop::packages
  include ocf_desktop::printnotify
  include ocf_desktop::sshfs
  include ocf_desktop::stats
  include ocf_desktop::steam
  include ocf_desktop::suspend
  include ocf_desktop::tmpfs
  include ocf_desktop::udev
  include ocf_desktop::wireshark
  include ocf_desktop::xsession

  $opstaff_workstation = lookup('opstaff')

  # Add the printing credentials only on opstaff desktop
  if $opstaff_workstation {
    file {
      '/etc/ocfprinting.json':
        source    => 'puppet:///private/ocfprinting.json',
        group     => opstaff,
        mode      => '0640',
        show_diff => false;
    }
  }

  # Allow HTTP and HTTPS
  include ocf::firewall::allow_web

  # Allow Steam login and Steam content
  ocf::firewall::firewall46 {
    '101 allow steam (tcp)':
      opts => {
        chain  => 'PUPPET-INPUT',
        proto  => 'tcp',
        dport  => ['27015-27030', '27036', '27037'],
        action => 'accept',
      };
  }
  ocf::firewall::firewall46 {
    '101 allow steam (udp)':
      opts => {
        chain  => 'PUPPET-INPUT',
        proto  => 'udp',
        dport  => ['4380', '27000-27031', '27036'],
        action => 'accept',
      };
  }
}
