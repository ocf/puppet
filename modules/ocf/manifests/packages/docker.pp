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
  class { 'ocf::packages::docker::apt':
    stage => first,
  }

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

  cron {
    'clean-old-docker-containers':
      command => "docker ps -a --filter status=exited | grep -E '(weeks?|months?|years?) ago' | awk '{print \$1}' | chronic xargs -r docker rm",
      hour    => 1,
      minute  => 3;

    'clean-docker-images':
      # Chronic doesn't work well here because docker rmi likes to raise errors
      # about images still linked to containers
      command => 'docker images -q --filter dangling=true | xargs -r docker rmi > /dev/null 2>&1',
      hour    => 1,
      minute  => 17;

    'clean-docker-volumes':
      # TODO: use docker volume prune when we get docker 1.13+
      command => 'docker volume ls -q --filter dangling=true | chronic xargs -r docker volume rm',
      hour    => 1,
      minute  => 25;
  }
}
