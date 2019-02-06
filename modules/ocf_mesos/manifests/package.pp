class ocf_mesos::package {
  class { 'ocf_mesos::package::first_stage':
    stage => first,
  }

  # at this time, v1.7.1 requires glibc >= 2.27 but stretch provides 2.24
  $mesos_version = '1.7.0-2.0.3'

  # We need Java 8 to be the default java.
  include ocf::packages::java
  ocf::repackage { 'mesos':
    # mesos recommends zookeeper
    recommends => false;
  } ->
  apt::pin { 'mesos':
    ensure   => present,
    packages => ['mesos'],
    priority => 1001,
    version  => $mesos_version;
  }

  # TODO: if we decide that we *won't* have servers which are both masters and
  # agents (we don't currently), we could simplify this
  $is_master = tagged('ocf_mesos::master')
  $is_slave = tagged('ocf_mesos::slave') and !lookup('ocf_mesos::slave::disabled', {default_value => false})
  service {
    'mesos-master':
      ensure  => $is_master,
      enable  => $is_master,
      require => Ocf::Repackage['mesos'];
    'mesos-slave':
      ensure  => $is_slave,
      enable  => $is_slave,
      require => Ocf::Repackage['mesos'];
  }
}
