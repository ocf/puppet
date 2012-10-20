class ocf::desktop::numlockx {
  # provide non lxpanel fail
  file { '/etc/X11/Xsession.d/55numlockx':
    source => 'puppet:///modules/ocf/desktop/55numlockx'
  }
}
