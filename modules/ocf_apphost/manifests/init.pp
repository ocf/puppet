class ocf_apphost {
  include common::extrapackages
  include common::nfs
  include proxy
  include ssl

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
