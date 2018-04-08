class ocf_ssh {
  include ocf::acct
  include ocf::extrapackages
  include ocf::hostkeys
  include ocf::limits
  include ocf::packages::cups
  include ocf_ssl::default_bundle

  class { 'ocf::nfs':
    cron => true,
    web  => true;
  }

  include ocf_ssh::makeservices
  include ocf_ssh::webssh
}
