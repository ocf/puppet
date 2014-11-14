class ocf_ssh {
  include ocf_ssl
  include common::acct
  include common::cups
  include common::limits
  include common::mysql

  class { 'common::nfs':
    pykota => true;
  }

  include legacy
  include hostkeys
  include webssh

  mount { '/tmp':
    device  => 'tmpfs',
    fstype  => 'tmpfs',
    options => 'noatime,nodev,nosuid';
  }
}
