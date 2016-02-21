class ocf_mesos::chronos {
  package { 'chronos':; }
  service { 'chronos':
    ensure  => running,
    require => Package['chronos'],
  }

  File {
    notify    => Service['chronos'],
    require   => Package['chronos', 'mesos'],
  }

  file {
    '/etc/chronos/conf/mail_from':
      content => "root@ocf.berkeley.edu\n";
    '/etc/chronos/conf/mail_server':
      content => "smtp:25\n";
    '/etc/chronos/conf/master':
      content => "mesos.ocf.berkeley.edu:5050\n";
    '/etc/chronos/conf/zk_hosts':
      content => "localhost:2181\n";
  }
}
