class ocf_desktop::modprobe {
  file {
    '/etc/modprobe.d/ocf-blacklist.conf':
      mode   => '0644',
      owner  => root,
      group  => root,
      source => 'puppet:///modules/ocf_desktop/modprobe.d/ocf-blacklist.conf';
  }
}
