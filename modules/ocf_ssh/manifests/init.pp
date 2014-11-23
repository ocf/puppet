class ocf_ssh {
  include common::acct
  include common::cups
  include common::extrapackages
  include common::limits
  include common::mysql
  include ocf_ssl

  package {
    # remove accidentally-installed packages
    ['php5', 'libapache2-mod-php5', 'apache2']:
      ensure => purged;
  }

  class { 'common::nfs':
    pykota => true;
  }

  include hostkeys
  include legacy
  include makeservices
  include webssh

  mount { '/tmp':
    device  => 'tmpfs',
    fstype  => 'tmpfs',
    options => 'noatime,nodev,nosuid';
  }
}
