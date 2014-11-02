class ocf_apphost {
  include common::nfs
  include proxy
  include ssl

  # useful for supervising user processes
  package { 'daemontools':; }

  file {
    '/srv/apps':
      ensure => directory,
      mode   => '0755';
  }
}
