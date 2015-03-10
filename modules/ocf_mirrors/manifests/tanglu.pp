class ocf_mirrors::tanglu {
  exec { 'get-ftpsync-tanglu':
    command => 'wget -O - -q https://ftp-master.debian.org/ftpsync.tar.gz | tar xvfz - -C /opt/mirrors/project/tanglu',
    user    => 'mirrors',
    creates => '/opt/mirrors/project/tanglu/distrib',
    require => File['/opt/mirrors/project/tanglu'];
  }

  File {
    owner => mirrors,
    group => mirrors
  }

  file {
    ['/opt/mirrors/project/tanglu', '/opt/mirrors/project/tanglu/log', '/opt/mirrors/project/tanglu/etc']:
      ensure  => directory,
      mode    => '0755';
    '/opt/mirrors/project/tanglu/bin':
      ensure  => link,
      links   => manage,
      target  => '/opt/mirrors/project/tanglu/distrib/bin',
      require => Exec['get-ftpsync-tanglu'];
    '/opt/mirrors/project/tanglu/etc/ftpsync.conf':
      source  => 'puppet:///modules/ocf_mirrors/project/tanglu/ftpsync.conf',
      mode    => '0644';
    '/opt/mirrors/project/tanglu/sync-releases':
      source  => 'puppet:///modules/ocf_mirrors/project/tanglu/sync-releases',
      mode    => '0755';
    '/opt/mirrors/project/tanglu/etc/common':
      ensure  => link,
      links   => manage,
      target  => '/opt/mirrors/project/tanglu/distrib/etc/common';
  }

  cron {
    'tanglu':
      ensure  => absent,
      command => 'BASEDIR=/opt/mirrors/project/tanglu /opt/mirrors/project/tanglu/bin/ftpsync',
      user    => 'mirrors',
      hour    => '*/4',
      minute  => '32';

    'tanglu-releases':
      ensure  => absent,
      command => '/opt/mirrors/project/tanglu/sync-releases > /dev/null',
      user    => 'mirrors',
      hour    => '*/2',
      minute  => '53';
  }
}
