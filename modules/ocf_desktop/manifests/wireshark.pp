class ocf_desktop::wireshark {
  package {
    'wireshark-common':
      responsefile => '/var/cache/debconf/wireshark-common.preseed',
      require      => File['/var/cache/debconf/wireshark-common.preseed'];

    'wireshark':;
  }

  file {
    '/var/cache/debconf/wireshark-common.preseed':
      source => 'puppet:///modules/ocf_desktop/wireshark-common.preseed';
  }
}
