class ocf_mesos::master {
  include ocf_mesos::master::load_balancer

  $my_mesos_id = $::hostname ? {
    whirlwind => 0,  # mesos0
    pileup    => 1,  # mesos1
    monsoon   => 2,  # mesos2
  }

  $mesos_hostname = "mesos${my_mesos_id}"
  $marathon_hostname = "marathon${my_mesos_id}"

  class {
    'ocf_mesos::master::mesos':
      mesos_hostname => $mesos_hostname;

    'ocf_mesos::master::marathon':
      marathon_hostname => $marathon_hostname;

    # Zookeeper needs IDs in the range [1, 255]
    'ocf_mesos::master::zookeeper':
      zookeeper_id => $my_mesos_id + 1;

    'ocf_mesos::master::webui':
      mesos_fqdn => "${mesos_hostname}.ocf.berkeley.edu",
      marathon_fqdn => "${marathon_hostname}.ocf.berkeley.edu";
  }
}
