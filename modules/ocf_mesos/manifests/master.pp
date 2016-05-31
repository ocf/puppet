class ocf_mesos::master {
  include ocf_mesos::master::load_balancer
  include ocf_mesos::master::marathon

  $my_mesos_id = $::hostname ? {
    whirlwind => 0,  # mesos0
    pileup    => 1,  # mesos1
    monsoon   => 2,  # mesos2
  }

  class {
    'ocf_mesos::master::mesos':
      mesos_hostname => "mesos${my_mesos_id}";

    # Zookeeper needs IDs in the range [1, 255]
    'ocf_mesos::master::zookeeper':
      zookeeper_id => $my_mesos_id + 1;
  }
}
