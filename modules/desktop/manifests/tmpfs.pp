class desktop::tmpfs {

  # mount certain volatile directories in memory
  mount {
    '/home':
      device  => 'tmpfs',
      fstype  => 'tmpfs',
      options => 'mode=0755,noatime,nodev,nosuid';
    '/tmp':
      device  => 'tmpfs',
      fstype  => 'tmpfs',
      options => 'noatime,nodev,nosuid';
    '/var/tmp':
      device  => 'tmpfs',
      fstype  => 'tmpfs',
      options => 'noatime,nodev,nosuid'
  }

  # create pam_mkhomedir profile
  file { '/usr/share/pam-configs/mkhomedir':
    source  => 'puppet:///modules/desktop/pam/mkhomedir',
    require => Mount['/home'],
    notify  => Exec['pam-auth-update']
  }

}
