# Install and configure Docker.
#
# The admin group *must* only contain trusted users (e.g. staff), as Docker
# containers can be used to compromise the host in many scenarios (e.g.
# mounting local filesystems, messing with network interfaces, more readily
# exploiting kernel bugs, etc.).
#
# Containers are helpful for testing things. For example:
#   docker run -i debian:jessie bash
#
# It would be cool to build an image with our base Puppet config to get even
# more use out of them, but that requires quite a bit of work first.
#
class ocf::packages::docker($admin_group = 'docker') {
  package {
    'docker.io':
      ensure  => purged;
    'docker-engine':
      require => Package['docker.io'];
  }

  exec { 'docker-socket-update':
    command     => 'systemctl daemon-reexec && systemctl restart docker.socket',
    refreshonly => true,
    require     => Package['docker-engine'],
  }

  augeas { 'set docker socket group':
    context => '/files/lib/systemd/system/docker.socket',
    changes => [
      "set Socket/SocketGroup/value ${admin_group}",
    ],
    require => Package['docker-engine'],
    notify  => Exec['docker-socket-update'];
  }
}
