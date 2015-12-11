class ocf::packages::rsync {
  package { 'rsync':; }

  # a wrapper script which ignores vanished files;
  # taken from https://download.samba.org/pub/unpacked/rsync/support/rsync-no-vanished
  file { '/usr/local/bin/rsync-no-vanished':
    source => 'puppet:///modules/ocf/packages/rsync-no-vanished',
    mode   => '0755';
  }
}
