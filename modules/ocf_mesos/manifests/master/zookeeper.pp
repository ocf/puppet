class ocf_mesos::master::zookeeper($zookeeper_id) {
  include ocf_mesos::package

  File {
    require => Package['zookeeper'],
    notify  => Service['zookeeper'],
  }

  # We provide our own service file because the init script that the mesosphere
  # package ships results in systemd losing track of the process somehow
  # (making it impossible to stop via service/systemctl).
  ocf::systemd::service { 'zookeeper':
    ensure  => running,
    source  => 'puppet:///modules/ocf_mesos/master/zookeeper/zookeeper.service',
    enable  => true,
  }

  file {
    '/etc/zookeeper/conf_ocf':
      ensure => directory;
    '/etc/zookeeper/conf_ocf/myid':
      content => "${zookeeper_id}\n";
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
