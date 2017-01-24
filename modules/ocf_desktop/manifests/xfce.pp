class ocf_desktop::xfce {
  ocf::repackage { ['xfce4', 'xfce4-goodies', 'xfce4-notifyd']:
    recommends => false;
  }

  file {
    # enable kiosk mode (disables shutdown, etc.)
    '/etc/xdg/xfce4/kiosk':
      ensure  => directory,
      source  => 'puppet:///modules/ocf_desktop/xsession/xfce4/kiosk/',
      recurse => true;
    '/etc/xdg/xfce4/xfconf':
      ensure  => directory,
      source  => 'puppet:///modules/ocf_desktop/xsession/xfce4/xfconf/',
      recurse => true;
    '/opt/share/xsession/penguin-for-menu.png':
      source  => 'puppet:///modules/ocf_desktop/xsession/xfce4/penguin-for-menu.png';
  }

  if $::lsbdistcodename != 'jessie' {
    file {
      # Overwrite panel definition on stretch to remove second logout button
      # and add audio adjustment plugin
      '/etc/xdg/xfce4/xfconf/xfce-perchannel-xml/xfce4-panel.xml':
        source  => 'puppet:///modules/ocf_desktop/xsession/xfce4/xfce4-panel-stretch.xml',
        require => File['/etc/xdg/xfce4/xfconf'];
    }
  }
}
