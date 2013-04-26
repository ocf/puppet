class ocf::local::eruption {
  # because ocf staff loves hosing, use persistent homedirs
  # this is just ocf::desktop::tmpfs without the /home mount

  mount {
    '/tmp':
      device  => 'tmpfs',
      fstype  => 'tmpfs',
      options => 'noatime,nodev,nosuid';
    '/var/lock':
      device  => 'tmpfs',
      fstype  => 'tmpfs',
      options => 'noatime,nodev,noexec,nosuid';
    '/var/run':
      device  => 'tmpfs',
      fstype  => 'tmpfs',
      options => 'mode=0755,noatime,nodev,noexec,nosuid';
    '/var/tmp':
      device  => 'tmpfs',
      fstype  => 'tmpfs',
      options => 'noatime,nodev,nosuid'
  }

  # create pam_mkhomedir profile
  file { '/usr/share/pam-configs/mkhomedir':
    source  => 'puppet:///modules/ocf/desktop/pam/mkhomedir',
    notify  => Exec['pam-auth-update']
  }

}
