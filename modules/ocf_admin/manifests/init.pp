class ocf_admin {
  include ocf::extrapackages
  include ocf::hostkeys
  include ocf::ldapvi
  include ocf::mysql

  include apt_dater
  include create

  class { 'ocf::nfs':
    pykota => true,
    cron   => true,
    web    => true;
  }

  class { 'ocf::docker':
    admin_group => 'ocfroot';
  }
}
