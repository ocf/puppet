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
class ocf::packages::docker($admin_group = undef,
                            $autoclean = true,
                            $image_max_age = '24h',
                            $container_max_age = '24h',
                            $prune_volumes = true) {
  class { 'ocf::packages::docker::apt':
    stage => first,
  }

  if $::lsbdistcodename != 'jessie' {
    package {
      ['aufs-dkms', 'aufs-tools']:
        ensure => purged;
    }
  }

  # Don't install AUFS stuff
  ocf::repackage {
    'docker-ce':
      recommends => false,
  }

  exec { 'docker-socket-update':
    command     => 'systemctl restart docker.socket',
    refreshonly => true,
    require     => Exec['systemd-reload'],  # which is triggered by ocf::systemd::override
  }

  if $admin_group != undef {
    ocf::systemd::override { 'set-docker-socket-group':
      unit    => 'docker.socket',
      content => "[Socket]\nSocketGroup=${admin_group}\n",
      require => Package['docker-ce'],
      notify  => Exec['docker-socket-update'];
    }
  }

  if $autoclean {
    cron {
      'clean-old-docker-containers':
        command => "chronic docker container prune --filter until=${container_max_age} -f",
        hour    => 1,
        minute  => 3;

      'clean-docker-images':
        command => "chronic docker image prune -a --filter until=${image_max_age} -f",
        hour    => 1,
        minute  => 17;

      'clean-docker-networks':
        command => 'chronic docker network prune -f',
        hour    => 1,
        minute  => 25;
    }

    if $prune_volumes {
      cron {
        'clean-docker-volumes':
          command => 'chronic docker volume prune -f',
          hour    => 1,
          minute  => 30;
      }
    }
  }
}
