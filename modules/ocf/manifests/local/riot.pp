class ocf::local::riot {

  package { 'pulseaudio': }

  user { 'kiosk':
      comment => 'Lab Display',
      home    => '/opt/kiosk',
      shell   => '/opt/kiosk/shell',
      system  => true,
      groups  => 'sys',
  }

  file {
      '/etc/apt/sources.list.d/raspbian.list':
          ensure   => file,
          content  => "deb http://archive.raspbian.org/raspbian wheezy main contrib non-free\ndeb-src http://archive.raspbian.org/raspbian wheezy main contrib non-free\n",
      ;
      '/opt/kiosk/':
          ensure   => directory,
          purge    => true,
      ;
      '/opt/kiosk/display':
          source   => 'puppet:///modules/ocf/local/riot/display',
          mode     => '0755',
      ;
      '/opt/kiosk/shell':
          source   => 'puppet:///modules/ocf/local/riot/shell',
          mode     => '0755',
      ;
      '/etc/inittab':
          source   => 'puppet:///modules/ocf/local/riot/inittab',
      ;
      '/etc/cron.d/update-motd':
          source   => 'puppet:///modules/ocf/local/riot/crontab',
      ;
  }

}
