class ocf_mesos::package {
  class { 'ocf_mesos::package::first_stage':
    stage => first,
  }

  # We need Java 8 to be the default java.
  include ocf::packages::java
  package { ['mesos', 'zookeeper']:; }

  $is_master = tagged('ocf_mesos::master')
  $is_slave = tagged('ocf_mesos::slave')
  service {
    'mesos-master':
      ensure => $is_master,
      enable => $is_master,
      require => Package['mesos'];
    'zookeeper':
      ensure => $is_master,
      enable => $is_master,
      require => Package['mesos'];
    'mesos-slave':
      ensure => $is_slave,
      enable => $is_slave,
      require => Package['mesos'];
  }
}
