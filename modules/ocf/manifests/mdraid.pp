class ocf::mdraid {
  package { 'mdadm':; }

  file { '/usr/local/sbin/mdraid-cron':
    source => 'puppet:///modules/ocf/mdraid/mdraid-cron',
    mode   => '0755';
  }

  # the mdadm package ships with a `mdmonitor` systemd unit that should alert
  # us via email, but we have our own cron job as well (just in case!)
  cron { 'mdraid-cron':
    command => '/usr/local/sbin/mdraid-cron',
    minute  => '*',
    require => [
      File['/usr/local/sbin/mdraid-cron'],
      Package['mdadm'],
    ];
  }
}
