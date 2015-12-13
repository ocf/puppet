class ocf_mirrors::ubuntu {
  exec { 'get-ftpsync-ubuntu':
    command => 'wget -O - -q https://ftp-master.debian.org/ftpsync.tar.gz | tar xvfz - -C /opt/mirrors/project/ubuntu',
    user    => 'mirrors',
    creates => '/opt/mirrors/project/ubuntu/distrib',
    require => File['/opt/mirrors/project/ubuntu'];
  }

  File {
    owner => mirrors,
    group => mirrors
  }

  file {
    ['/opt/mirrors/project/ubuntu', '/opt/mirrors/project/ubuntu/log', '/opt/mirrors/project/ubuntu/etc']:
      ensure  => directory,
      mode    => '0755';

    '/opt/mirrors/project/ubuntu/sync-releases':
      source  => 'puppet:///modules/ocf_mirrors/project/ubuntu/sync-releases',
      mode    => '0755';

    '/opt/mirrors/project/ubuntu/bin':
      ensure  => link,
      target  => '/opt/mirrors/project/ubuntu/distrib/bin',
      require => Exec['get-ftpsync-ubuntu'];

    '/opt/mirrors/project/ubuntu/etc/common':
      ensure  => link,
      target  => '/opt/mirrors/project/ubuntu/distrib/etc/common',
      require => Exec['get-ftpsync-ubuntu'];

    '/opt/mirrors/project/ubuntu/etc/ftpsync.conf':
      source  => 'puppet:///modules/ocf_mirrors/project/ubuntu/ftpsync.conf',
      mode    => '0644';
  }

  cron {
    'ubuntu':
      command => 'BASEDIR=/opt/mirrors/project/ubuntu /opt/mirrors/project/ubuntu/bin/ftpsync',
      user    => 'mirrors',
      hour    => '*',
      minute  => '15';

    'ubuntu-releases':
      command => '/opt/mirrors/project/ubuntu/sync-releases > /dev/null',
      user    => 'mirrors',
      hour    => '*/7',
      minute  => '18';
  }
}
