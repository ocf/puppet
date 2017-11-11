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
}
