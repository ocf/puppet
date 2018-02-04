class ocf_admin {
  include ocf::extrapackages
  include ocf::firewall::output_all
  include ocf::hostkeys
  include ocf::packages::cups
  include ocf::tmpfs
  include ocf_ocfweb::dev_config

  include ocf_admin::apt_dater
  include ocf_admin::create

  class { 'ocf::nfs':
    cron  => true,
    web   => true;
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
    '/etc/ocfstats-ro.passwd':
      source => 'puppet:///private/ocfstats-ro.passwd',
      group  => ocfstaff,
      mode   => '0640';
  }
}
