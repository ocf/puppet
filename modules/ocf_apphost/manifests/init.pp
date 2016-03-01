class ocf_apphost {
  include ocf::extrapackages
  include ocf::hostkeys
  include ocf::motd
  include proxy
  include ssl

  class { 'ocf::nfs':
    cron => true;
  }

  # useful for supervising user processes
  package { 'daemontools':; }

  file {
    '/srv/apps':
      ensure => directory,
      mode   => '0755';
  }
}
