class desktop::numlockx {
  # provide non lxpanel fail
  file { '/etc/X11/Xsession.d/55numlockx':
    source => 'puppet:///modules/desktop/55numlockx'
  }
}
