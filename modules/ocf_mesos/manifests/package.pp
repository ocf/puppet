class ocf_mesos::package {
  class { 'ocf_mesos::package::apt':
    stage => first,
  }

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
    # We only use zookeeper for Chronos persistence, not for Mesos redundant
    # masters.
    'zookeeper':
      ensure => $is_master,
      enable => $is_master;
    'mesos-slave':
      ensure => $is_slave,
      enable => $is_slave;
  }
}
