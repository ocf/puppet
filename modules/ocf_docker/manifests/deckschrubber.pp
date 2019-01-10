class ocf_docker::deckschrubber {
  package { 'deckschrubber': }

  file { ['/opt/docker', '/opt/docker/registry']:
    ensure => directory,
    mode   => '0755',
  } ->
  file { '/opt/docker/registry/garbage-collect':
    source  => 'puppet:///modules/ocf_docker/garbage-collect',
    mode    => '0755',
    require => Package['deckschrubber'],
  } ->
  cron { 'registry-gc':
    command  => '/opt/docker/registry/garbage-collect',
    user     => 'root',
    monthday => 1,
    hour     => 7,
    minute   => 0,
  }
}
