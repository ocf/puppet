class ocf_mesos::package {
  # We need Java 8 to be the default java.
  include ocf::packages::java
  package { ['mesos', 'zookeeper']:; }

  Service {
    require => Package['mesos'],
  }

  $is_master = tagged('ocf_mesos::master')
  $is_slave = tagged('ocf_mesos::slave')
  service {
    'mesos-master':
      ensure => $is_master,
      enable => $is_master;
    'zookeeper':
      ensure => $is_master,
      enable => $is_master;
    'mesos-slave':
      ensure => $is_slave,
      enable => $is_slave;
  }
}
