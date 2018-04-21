class ocf_mesos::master {
  include ocf_mesos
  include ocf_mesos::secrets

  # Desktops are mesos agents, and there are too many ports to keep track of easily.
  include ocf::firewall::allow_desktops

  file { '/opt/share/mesos/master':
    ensure => directory,
  }

  $mesos_masters = lookup('mesos_masters')

  $my_mesos_id = $mesos_masters[$::hostname]
  $mesos_hostname = "mesos${my_mesos_id}"
  $marathon_hostname = "marathon${my_mesos_id}"

  $mesos_http_password = hiera('mesos::master::password')
  $mesos_agent_http_password = hiera('mesos::slave::password')
  $marathon_http_password = hiera('mesos::marathon::http_password')
  $zookeeper_password = hiera('mesos::zookeeper::password')

  # TODO: can we not duplicate this between slave/master?
  # looks like: mesos0:2181,mesos1:2181,mesos2:2181
  $zookeeper_host = join(keys($mesos_masters).map |$m| { "${m}:2181" }, ',')
  $zookeeper_uri = "zk://ocf:${zookeeper_password}@${zookeeper_host}"

  class {
    'ocf_mesos::master::mesos':
      mesos_hostname      => $mesos_hostname,
      mesos_http_password => $mesos_http_password,
      masters             => $mesos_masters,
      zookeeper_uri       => $zookeeper_uri;

    'ocf_mesos::master::load_balancer':
      marathon_http_password => $marathon_http_password;

    'ocf_mesos::master::marathon':
      marathon_hostname   => $marathon_hostname,
      http_password       => $marathon_http_password,
      mesos_http_password => $mesos_http_password,
      zookeeper_host      => $zookeeper_host;

    # Zookeeper needs IDs in the range [1, 255]
    'ocf_mesos::master::zookeeper':
      masters            => $mesos_masters,
      zookeeper_password => $zookeeper_password;

    'ocf_mesos::master::webui':
      mesos_fqdn                => "${mesos_hostname}.ocf.berkeley.edu",
      mesos_http_password       => $mesos_http_password,
      mesos_agent_http_password => $mesos_agent_http_password,
      marathon_fqdn             => "${marathon_hostname}.ocf.berkeley.edu",
      marathon_http_password    => $marathon_http_password;

    'ocf_mesos::master::dns':
      zookeeper_host      => $zookeeper_host,
      mesos_http_password => $mesos_http_password;
  }
}
