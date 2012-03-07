class ocf::local::surge {

  # set up mirror sync
  # add user to perform sync
  user { 'debmirror':
    comment  => 'OCF Environmental Mirroring',
    home     => '/opt/debmirror',
    shell    => '/bin/sh',
    groups   => 'sys',
    require  => File['/opt/debmirror']
  }
  exec { 'ftpsync':
    command  => 'git clone https://ftp-master.debian.org/git/archvsync.git /opt/debmirror',
    creates  => '/opt/debmirror/bin',
    require  => File['/opt/debmirror']
  }
  file {
    '/opt/debmirror':
      ensure  => directory;
    '/opt/debmirror/data':
      ensure  => directory,
      owner   => debmirror,
      group   => debmirror,
      require => Exec['ftpsync'];
    '/opt/debmirror/log':
      ensure  => directory,
      owner   => debmirror,
      group   => debmirror,
      require => Exec['ftpsync'];
    '/opt/debmirror/etc/ftpsync.conf':
      source  => 'puppet:///modules/ocf/local/surge/ftpsync.conf',
      require => Exec['ftpsync']
  }
  # add cronjob to sync twice daily
  cron { 'debmirror':
    command => '$HOME/bin/ftpsync',
    user    => 'debmirror',
    hour    => [ 07, 19 ],
    minute  => 14,
    require => [ User['debmirror'], File['/opt/debmirror', '/opt/debmirror/data', '/opt/debmirror/log', '/opt/debmirror/etc/ftpsync.conf' ] ]
  }

  # set up mirror server
  package { 'apache2': }
  file {
    '/etc/apache2/sites-available/debmirror':
      source => 'puppet:///modules/ocf/local/surge/apache';
    '/etc/apache2/sites-enabled/debmirror':
      ensure => symlink,
      target => '/etc/apache2/sites-available/debmirror'
  }
  service { 'apache2':
    subscribe => File[ '/etc/apache2/sites-available/debmirror', '/etc/apache2/sites-enabled/debmirror' ],
    require   => File['/opt/debmirror']
  }

  # set up rsync server
  user { 'rsync':
    home    => '/opt/debmirror/data',
    shell   => '/bin/false',
    require => File['/opt/debmirror'],
  }
  file {
    '/etc/default/rsync':
      content => 'RSYNC_ENABLE=true';
    '/etc/rsyncd.conf':
      source  => 'puppet:///modules/ocf/local/surge/rsyncd.conf'
  }
  service { 'rsync':
    subscribe => File[ '/etc/default/rsync', '/etc/rsyncd.conf' ],
    require   => User['rsync']
  }

  # set up tftp for network booting
  package { 'tftpd-hpa': }
  file {
    '/opt/tftp':
      ensure  => directory;
    '/etc/default/tftpd-hpa':
      source  => 'puppet:///modules/ocf/local/surge/tftpd-hpa',
      require => [ Package['tftpd-hpa'], File['/opt/tftp'] ]
  }
  service { 'tftpd-hpa':
    subscribe => File[ '/opt/tftp', '/etc/default/tftpd-hpa' ]
  }

  # set up netboot image
  package { 'pax': }
  file {
    '/usr/local/sbin/ocf-netboot':
      mode    => 0755,
      source  => 'puppet:///modules/ocf/local/surge/ocf-netboot',
      require => Package['pax'];
    '/etc/cron.weekly/ocf-netboot':
      ensure  => symlink,
      target  => '/usr/local/sbin/ocf-netboot'
  }

}
