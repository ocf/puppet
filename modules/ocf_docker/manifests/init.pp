class ocf_docker {
  include ocf::packages::docker
  require ocf_ssl

  file { '/var/lib/registry':
    ensure => directory,
  }

  ocf::systemd::service { 'docker-registry':
    content => template('ocf_docker/docker-registry.service.erb'),
    require => [
      Package['docker-engine'],
      File['/var/lib/registry'],
    ],
  }
}
