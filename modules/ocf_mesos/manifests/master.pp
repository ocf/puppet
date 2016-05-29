class ocf_mesos::master {
  include ocf_mesos::master::load_balancer
  include ocf_mesos::master::marathon
  include ocf_mesos::master::mesos
  include ocf_mesos::master::zookeeper
}
