# Install and configure Docker.
#
# The admin group *must* only contain trusted users (e.g. staff), as Docker
# containers can be used to compromise the host in many scenarios (e.g.
# mounting local filesystems, messing with network interfaces, more readily
# exploiting kernel bugs, etc.).
#
# Containers are helpful for testing things. For example:
#   docker run -ti debian:jessie bash
#
class ocf::packages::docker($admin_group = undef) {
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
    command     => 'systemctl daemon-reload && systemctl restart docker.socket',
    refreshonly => true,
    require     => Package['docker-engine'],
  }

  if $admin_group != undef {
    ocf::systemd::override { 'set-docker-socket-group':
      unit    => 'docker.socket',
      content => "[Socket]\nSocketGroup=${admin_group}\n",
      require => Package['docker-engine'],
      notify  => Exec['docker-socket-update'];
    }
  }

  if $::lsbdistcodename != 'jessie' {
    # Use overlay2 storage driver
    ocf::systemd::override { 'cmd':
      unit    => 'docker.service',
      content => "[Service]\nExecStart=\nExecStart=/usr/bin/dockerd -H fd:// --storage-driver=overlay2\n",
      require => Package['docker-engine'],
    }
  }

  cron {
    'clean-old-docker-containers':
      # days is intentionally plural
      command => "docker ps -a --filter status=exited | grep -E 'Exited \\([0-9]+\\) [0-9]+ (days|weeks?|months?|years?) ago' | awk '{print \$1}' | chronic xargs -r docker rm",
      hour    => 1,
      minute  => 3;

    'clean-old-created-docker-containers':
      # days is intentionally plural
      command => "docker ps -a --filter status=created | grep -E '(days|weeks?|months?|years?) ago' | awk '{print \$1}' | chronic xargs -r docker rm",
      hour    => 1,
      minute  => 5;

    'clean-docker-images':
      # TODO: use docker image prune -a --filter until=<timestamp> when on 1.14+
      # Chronic doesn't work well here because docker rmi likes to raise errors
      # about images still linked to containers
      command => 'docker images -q --filter dangling=true | xargs -r docker rmi > /dev/null 2>&1',
      hour    => 1,
      minute  => 17;

    'clean-docker-volumes':
      command => 'chronic docker volume prune -f',
      hour    => 1,
      minute  => 25;
  }
}
