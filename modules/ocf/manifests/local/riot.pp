class ocf::local::riot {

  package { 'pulseaudio': }
  service { 'pulseaudio': }

  user { 'kiosk':
      comment => 'Lab Display',
      home    => '/opt/kiosk',
      shell   => '/opt/kiosk-bin/shell',
      system  => true,
      groups  => ['sys', 'pulse-access'],
      require => Package['pulseaudio'],
  }

  file {
      '/etc/default/pulseaudio':
          source   => 'puppet:///modules/ocf/local/riot/pulseaudio',
          notify   => Service['pulseaudio'],
      ;
      '/opt/kiosk/':
          ensure   => directory,
          owner    => 'kiosk',
          purge    => true,
      ;
      '/opt/kiosk-bin':
          ensure   => directory,
          purge    => true,
      ;
      '/opt/kiosk-bin/display':
          source   => 'puppet:///modules/ocf/local/riot/display',
          mode     => '0755',
      ;
      '/opt/kiosk-bin/shell':
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
