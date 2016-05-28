class ocf_mesos::package {
  package { 'mesos':; }

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
      ensure => false,
      enable => false;
  }
}
