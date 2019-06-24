class ocf_desktop::defaults {
  # default applications for MIME types
  file { '/usr/share/applications/mimeapps.list':
    source  => 'puppet:///modules/ocf_desktop/xsession/mimeapps.list';
  }

  # temporary only, to get rid of files!
  file { '/usr/local/bin/pdf-open':
    ensure => absent;
  }

  file { '/usr/share/applications/pdfopen.desktop':
    ensure => absent;
  }
}
