# mount certain volatile directories in memory
class desktop::tmpfs ($staff = false) {
  if ! $staff {
    mount { '/home':
      device  => 'tmpfs',
      fstype  => 'tmpfs',
      options => 'mode=0755,noatime,nodev,nosuid';
    }
  }

  mount {
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
    source => 'puppet:///modules/desktop/pam/mkhomedir',
    notify => Exec['pam-auth-update']
  }
}
