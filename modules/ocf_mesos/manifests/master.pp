class ocf_mesos::master {
  include ocf_mesos
  include ocf_mesos::slave::secrets

  file { '/opt/share/mesos/master':
    ensure => directory;
  }

  $my_mesos_id = $::hostname ? {
    whirlwind => 0,  # mesos0
    pileup    => 1,  # mesos1
    monsoon   => 2,  # mesos2
  }

  $mesos_hostname = "mesos${my_mesos_id}"
  $marathon_hostname = "marathon${my_mesos_id}"

  $mesos_http_password = 'hunter2'
  $marathon_http_password = 'hunter4'

  class {
    'ocf_mesos::master::mesos':
      mesos_hostname      => $mesos_hostname,
      mesos_http_password => $mesos_http_password;

    'ocf_mesos::master::load_balancer':
      marathon_http_password => $marathon_http_password;

    'ocf_mesos::master::marathon':
      marathon_hostname   => $marathon_hostname,
      http_password       => $marathon_http_password,
      mesos_http_password => $mesos_http_password;

    # Zookeeper needs IDs in the range [1, 255]
    'ocf_mesos::master::zookeeper':
      zookeeper_id => $my_mesos_id + 1;

    'ocf_mesos::master::webui':
      mesos_fqdn             => "${mesos_hostname}.ocf.berkeley.edu",
      mesos_http_password    => $mesos_http_password,
      marathon_fqdn          => "${marathon_hostname}.ocf.berkeley.edu",
      marathon_http_password => $marathon_http_password;
  }
}
