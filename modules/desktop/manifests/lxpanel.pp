class desktop::lxpanel {
  # provide non lxpanel fail
  if  $::lsbdistcodename == 'squeeze' {
    file { '/usr/share/lxpanel/profile/LXDE/panels/panel':
      source => 'puppet:///modules/desktop/lxpanel.conf'
    }
  } else {
    file { '/usr/share/lxpanel/profile/default/panels/panel':
      source => 'puppet:///modules/desktop/lxpanel.conf'
    }
  }
}
