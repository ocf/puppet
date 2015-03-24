class ocf_csgo {
  user { 'ocfcsgo':
    comment => 'Counter-Strike Server',
    home    => '/opt/csgo',
    groups  => ['sys'],
    shell   => '/bin/false';
  }

  File {
    owner  => ocfcsgo,
    group  => ocfcsgo
  }

  file {
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
    'lib32gcc1':
      require => Exec['add-i386'];
  }

  exec {
    'add-i386':
      command => 'dpkg --add-architecture i386',
      unless  => 'dpkg --print-foreign-architectures | grep i386';

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
}
