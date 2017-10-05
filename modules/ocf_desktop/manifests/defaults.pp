class ocf_desktop::defaults {
  # default applications for MIME types
  file { '/usr/share/applications/mimeapps.list':
    source  => 'puppet:///modules/ocf_desktop/xsession/mimeapps.list';
  }

  file { '/usr/local/bin/pdf-open':
      mode    => '0755',
      source  => 'puppet:///modules/ocf_desktop/xsession/pdf-open',
      require => Package['libimage-exiftool-perl'];
  }

  file { '/usr/share/applications/pdfopen.desktop':
    source => 'puppet:///modules/ocf_desktop/xsession/pdfopen.desktop',
    require => File['/usr/local/bin/pdf-open'];
  }

  # /etc/alternatives/
  if $::lsbdistcodename == 'jessie' {
    exec { 'update-alternatives --set x-terminal-emulator /usr/bin/xfce4-terminal.wrapper':
      unless => '/usr/bin/test $(readlink /etc/alternatives/x-terminal-emulator) == "/usr/bin/xfce4-terminal.wrapper"';
    }
  }

}
