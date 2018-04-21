class ocf_csgo {
  include ocf::apt::i386

  user { 'ocfcsgo':
    comment => 'Counter-Strike Server',
    home    => '/opt/csgo',
    groups  => ['sys'],
    shell   => '/bin/false';
  }

  file {
    default:
      owner => ocfcsgo,
      group => ocfcsgo;

    ['/opt/csgo', '/opt/csgo/bin', '/opt/csgo/etc']:
      ensure => directory,
      mode   => '0755';

    '/opt/csgo/bin/update-csgo':
      source => 'puppet:///modules/ocf_csgo/bin/update-csgo',
      mode   => '0755';

    '/opt/csgo/etc/csgo-update.cmd':
      source => 'puppet:///modules/ocf_csgo/etc/csgo-update.cmd';
  }

  package {
    'lib32gcc1':;
  }

  exec {
    'download-steamcmd':
      command => 'curl http://media.steampowered.com/installer/steamcmd_linux.tar.gz | tar xzf - -C /opt/csgo/bin',
      user    => ocfcsgo,
      creates => '/opt/csgo/bin/steamcmd.sh',
      notify  => Exec['update-csgo'],
      require => File['/opt/csgo/bin'];

    'update-csgo':
      command     => '/opt/csgo/bin/update-csgo',
      user        => ocfcsgo,
      refreshonly => true,
      require     => [File['/opt/csgo/bin/update-csgo'], Package['lib32gcc1']];
  }

  ocf::munin::plugin { 'csgo':
    source => 'puppet:///modules/ocf_csgo/munin';
  }

  # Firewall rules for dedicated server hosting
  include ocf::firewall::allow_http
  firewall_multi {
    '101 allow srcds_linux from desktops (IPv4)':
      chain     => 'PUPPET-INPUT',
      src_range => '169.229.226.100-169.229.226.139',
      proto     => 'all',
      action    => 'accept';

    '101 allow srcds_linux from desktops (IPv6)':
      provider  => 'ip6tables',
      chain     => 'PUPPET-INPUT',
      src_range => '2607:f140:8801::100-2607:f140:8801::139',
      proto     => 'all',
      action    => 'accept';
  }
}
