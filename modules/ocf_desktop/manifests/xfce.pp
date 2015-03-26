class ocf_desktop::xfce {
  ocf::repackage { ['xfce4', 'xfce4-goodies', 'xfce4-notifyd']:
    recommends => false;
  }

  # xfce4-power-manager asks for admin authentication on login in order to
  # "change laptop display brightness"
  package { 'xfce4-power-manager':
    ensure => absent;
  }

  file {
    # enable kiosk mode (disables shutdown, etc.)
    '/etc/xdg/xfce4/kiosk':
      ensure => directory,
      source => 'puppet:///modules/ocf_desktop/xsession/xfce4/kiosk/',
      recurse => true;
    '/etc/xdg/xfce4/xfconf':
      ensure => directory,
      source => 'puppet:///modules/ocf_desktop/xsession/xfce4/xfconf/',
      recurse => true;
  }
}
