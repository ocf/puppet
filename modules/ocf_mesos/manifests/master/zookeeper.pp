class ocf_mesos::master::zookeeper {
  include ocf_mesos::package

  $my_id = $::hostname ? {
    jaws     => 1,
    pandemic => 2,
    hal      => 3,
  }

  if $my_id == undef {
    fail("Master ${::hostname} is unknown!")
  }

  File {
    require => Package['zookeeper'],
    notify  => Service['zookeeper'],
  }

  file {
    '/etc/zookeeper/conf_ocf':
      ensure => directory;
    '/etc/zookeeper/conf_ocf/myid':
      content => "${my_id}\n";
    '/etc/zookeeper/conf_ocf/zoo.cfg':
      source  => 'puppet:///modules/ocf_mesos/master/zookeeper/zoo.cfg';
    '/etc/zookeeper/conf_ocf/environment':
      source  => 'puppet:///modules/ocf_mesos/master/zookeeper/environment';
    '/etc/zookeeper/conf_ocf/configuration.xsl':
      source  => 'puppet:///modules/ocf_mesos/master/zookeeper/configuration.xsl';
    '/etc/zookeeper/conf_ocf/log4j.properties':
      source  => 'puppet:///modules/ocf_mesos/master/zookeeper/log4j.properties';
    '/etc/zookeeper/conf':
      ensure  => link,
      target  => '/etc/zookeeper/conf_ocf';
  }
}
