class desktop::defaults {
  # default applications for MIME types
  file { '/usr/share/applications/mimeapps.list':
    source  => 'puppet:///modules/desktop/xsession/mimeapps.list';
  }

  # /etc/alternatives/
  exec { 'update-alternatives --set x-terminal-emulator /usr/bin/xfce4-terminal.wrapper':
    unless => '/usr/bin/test $(readlink /etc/alternatives/x-terminal-emulator) == "/usr/bin/xfce4-terminal.wrapper"';
  }
}
