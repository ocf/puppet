class desktop::xfce {
  package {
    ['xfce4', 'xfce4-goodies']:
      install_options => ['--no-install-recommends'];

    # xfce4-power-manager asks for admin authentication on login in order to
    # "change laptop display brightness"
    'xfce4-power-manager':
      ensure => absent;
  }

  file {
    # enable kiosk mode (disables shutdown, etc.)
    '/etc/xdg/xfce4/kiosk':
      ensure => directory,
      source => 'puppet:///modules/desktop/xsession/xfce4/kiosk/',
      recurse => true;
    '/etc/xdg/xfce4/xfconf':
      ensure => directory,
      source => 'puppet:///modules/desktop/xsession/xfce4/xfconf/',
      recurse => true;
  }
}
