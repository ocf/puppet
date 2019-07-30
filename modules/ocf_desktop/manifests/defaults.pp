class ocf_desktop::defaults {
  # default applications for MIME types
  file { '/usr/share/applications/mimeapps.list':
    source  => 'puppet:///modules/ocf_desktop/xsession/mimeapps.list';
  }
}
