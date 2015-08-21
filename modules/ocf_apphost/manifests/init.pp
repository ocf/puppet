class ocf_apphost {
  include ocf::extrapackages
  include ocf::hostkeys
  include proxy
  include ssl

  class { 'ocf::nfs':
    cron => true;
  }

  package {
    # remove accidentally-installed packages
    ['php5', 'libapache2-mod-php5', 'apache2']:
      ensure => purged;
  }

  # useful for supervising user processes
  package { 'daemontools':; }

  file {
    '/srv/apps':
      ensure => directory,
      mode   => '0755';
  }
}
