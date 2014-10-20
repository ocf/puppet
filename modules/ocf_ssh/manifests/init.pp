class ocf_ssh {
  include ocf_ssl
  class { 'common::nfs':
    pykota => true;
  }

  include ocf_ssh::legacy
  include ocf_ssh::hostkeys
  include ocf_ssh::webssh
}
