class tornado {

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
  
  exec { "rotate-display":
    command => "echo display_rotate=3 >> /boot/config.txt",
    unless  => "grep display_rotate /boot/config.txt";
  }

  exec { "disable-blanking":
    command => "sed -i 's/BLANK_TIME=.*/BLANK_TIME=0/' /etc/kbd/config",
    unless  => "grep BLANK_TIME=0 /etc/kbd/config";
  }

  file {
      '/etc/default/pulseaudio':
          source   => 'puppet:///modules/tornado/pulseaudio',
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
          source   => 'puppet:///modules/tornado/display',
          mode     => '0755',
      ;
      '/opt/kiosk-bin/shell':
          source   => 'puppet:///modules/tornado/shell',
          mode     => '0755',
      ;
      '/etc/inittab':
          source   => 'puppet:///modules/tornado/inittab',
      ;
      '/etc/cron.d/update-motd':
          source   => 'puppet:///modules/tornado/crontab',
      ;
      "/opt/kiosk-bin/monitor-power":
        source     => "puppet:///modules/tornado/monitor-power",
        mode       => 755;
  }
  
  cron { "monitor-power":
    command => "/opt/kiosk-bin/monitor-power > /dev/null",
    user    => root,
    hour    => "*",
    minute  => "*/5";
  }
}
