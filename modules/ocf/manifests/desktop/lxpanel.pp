class ocf::desktop::lxpanel {
  # provide non lxpanel fail
  file { '/usr/share/lxpanel/profile/LXDE/panels/panel':
    source => 'puppet:///modules/ocf/desktop/lxpanel.conf'
  }
}
