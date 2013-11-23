class desktop::modprobe {
  file {
    '/etc/modprobe.d/ocf-blacklist.conf':
      mode    => '0644',
      owner   => root,
      group   => root,
      source  => 'puppet:///modules/desktop/modprobe.d/ocf-blacklist.conf';
  }
}
