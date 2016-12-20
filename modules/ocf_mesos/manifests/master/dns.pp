# Runs mesos-dns:
# https://github.com/mesosphere/mesos-dns
#
# This makes it a lot easier to connect to the leader, and also potentially
# allows service discovery over DNS (though we don't really use that currently).
class ocf_mesos::master::dns(
    $mesos_http_password,
    $zookeeper_host,
) {
  # TODO: Include in stretch apt repo
  package { 'mesos-dns':; }

  file { '/opt/share/mesos/master/mesos-dns.json':
    content => template('ocf_mesos/master/dns/mesos-dns.json.erb'),
    mode    => '0600',
  }

  ocf::systemd::service { 'mesos-dns':
    ensure  => running,
    source  => 'puppet:///modules/ocf_mesos/master/dns/mesos-dns.service',
    enable  => true,
    require => [
      Package['mesos-dns'],
      File['/opt/share/mesos/master/mesos-dns.json'],
    ],
    subscribe => File['/opt/share/mesos/master/mesos-dns.json'],
  }
}
