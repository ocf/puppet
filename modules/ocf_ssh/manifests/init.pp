class ocf_ssh {
  include ocf::acct
  include ocf::extrapackages
  include ocf::hostkeys
  include ocf::limits
  include ocf::packages::cups
  include ocf::packages::mysql
  include ocf::tmpfs
  include ocf_ssl

  class { 'ocf::nfs':
    pykota => true,
    cron   => true,
    web    => true;
  }

  include legacy
  include makeservices
  include webssh
}
