class ocf_docker::deckschrubber {
  package { 'deckschrubber': }

  file { '/opt/share/puppet/docker-registry-clean':
    source  => 'puppet:///modules/ocf_docker/registry-clean',
    mode    => '0755',
    require => [
      Package['deckschrubber'],
      File['/var/lib/registry'],
      File['/opt/share/puppet'],
    ],
  } ->
  cron { 'registry-clean':
    command => 'chronic /opt/share/puppet/docker-registry-clean',
    weekday => 'Sunday',
    hour    => 7,
    minute  => 0,
  }
}
