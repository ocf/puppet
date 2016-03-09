class ocf_admin {
  include ocf::extrapackages
  include ocf::hostkeys
  include ocf::motd
  include ocf::packages::cups
  include ocf::packages::ldapvi
  include ocf::packages::mysql
  include ocf::tmpfs

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

  file {
    '/opt/passwords':
      source => 'puppet:///private/passwords',
      group  => ocfroot,
      mode   => '0640';
    '/etc/ocfprinting.json':
      source => 'puppet:///private/ocfprinting.json',
      group  => ocfstaff,
      mode   => '0640';
  }
}
