class ocf_admin {
  include ocf::extrapackages
  include ocf::hostkeys
  include ocf::packages::ldapvi
  include ocf::packages::mysql

  include apt_dater
  include create

  class { 'ocf::nfs':
    pykota => true,
    cron   => true,
    web    => true;
  }

  class { 'ocf::packages::docker':
    admin_group => 'ocfroot';
  }

  package {
    [
      'ipmitool',
      'wakeonlan',
    ]:;
  }
}
