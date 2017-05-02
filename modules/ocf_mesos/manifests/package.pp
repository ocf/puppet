class ocf_mesos::package {
  if $::lsbdistcodename == 'jessie' {
    class { 'ocf_mesos::package::first_stage':
      stage => first,
    }
  }

  # We need Java 8 to be the default java.
  include ocf::packages::java
  ocf::repackage { 'mesos':
    # mesos recommends zookeeper
    recommends => false,
  }

  # TODO: if we decide that we *won't* have servers which are both masters and
  # agents (we don't currently), we could simplify this
  $is_master = tagged('ocf_mesos::master')
  $is_slave = tagged('ocf_mesos::slave') and !hiera('ocf_mesos::slave::disabled', false)
  service {
    'mesos-master':
      ensure => $is_master,
      enable => $is_master,
      require => Ocf::Repackage['mesos'];
    'mesos-slave':
      ensure => $is_slave,
      enable => $is_slave,
      require => Ocf::Repackage['mesos'];
  }
}
