class ocf::local::riot {

  # raspbian repository
  file {
      '/etc/apt/sources.list.d/raspbian.list':
          ensure   => file,
          content  => "deb http://archive.raspbian.org/raspbian wheezy main contrib non-free\ndeb-src http://archive.raspbian.org/raspbian wheezy main contrib non-free\n";
      
      '/opt/kiosk/':
          ensure   => directory,
          owner    => 'root',
          group    => 'root',
          mode     => '0755';

      '/opt/kiosk/display':
          ensure   => file,
          source   => 'puppet:///modules/ocf/local/riot/display',
          owner    => 'root',
          group    => 'root',
          mode     => '0755';
      '/opt/kiosk/kiosk':
          ensure   => file,
          source   => 'puppet:///modules/ocf/local/riot/kiosk',
          owner    => 'root',
          group    => 'root',
          mode     => '0755';

      '/etc/inittab':
          ensure   => file,
          source   => 'puppet:///modules/ocf/local/riot/inittab',
          owner    => 'root',
          group    => 'root',
          mode     => '0644';
      
      '/etc/cron.d/update-motd':
          ensure   => file,
          source   => 'puppet:///modules/ocf/local/riot/crontab';
  }
}
