class ocf_ssh {
  include ocf::acct
  include ocf::cups
  include ocf::extrapackages
  include ocf::limits
  include ocf::mysql
  include ocf_ssl

  package {
    # remove accidentally-installed packages
    ['php5', 'libapache2-mod-php5', 'apache2']:
      ensure => purged;
  }

  class { 'ocf::nfs':
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
