class ocf_docker::deckschrubber {
  package { 'deckschrubber': }

  file { '/opt/share/puppet/registry-garbage-collect':
    source  => 'puppet:///modules/ocf_docker/garbage-collect',
    mode    => '0755',
    require => [
      Package['deckschrubber'],
      File['/var/lib/registry'],
      File['/opt/share/puppet'],
    ],
  } ->
  cron { 'registry-gc':
    command => '/opt/share/puppet/registry-garbage-collect',
    weekday => 'Sunday',
    hour    => 7,
    minute  => 0,
  }
}
