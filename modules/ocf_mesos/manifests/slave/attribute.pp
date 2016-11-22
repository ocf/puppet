# A free-form text attribute on a Mesos slave.
#
# For example, the "nfs" attribute can tag whether a slave has NFS available,
# and tasks can pin themselves to hosts with the "nfs:true" attribute.
#
# Note that changing attributes results in "incompatible agent info" and
# requires the agent's entire config to be deleted.
# http://www.flexthinker.com/2015/09/reconfiguring-mesos-agents-slaves-with-new-resources/
define ocf_mesos::slave::attribute($value) {
  if tagged('ocf_mesos::slave') {
    concat::fragment { "mesos-slave attribute: ${title}":
      content => "${title}:${value}",
      target  => '/etc/mesos-slave/attributes',
    }
  }
}
