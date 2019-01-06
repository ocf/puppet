class ocf::packages::java {
  package { 'openjdk-8-jre-headless':; }

  # Make Java 8 the default.
  file { '/etc/alternatives/java':
    ensure => link,
    target => '/usr/lib/jvm/java-8-openjdk-amd64/jre/bin/java',
  }
}
