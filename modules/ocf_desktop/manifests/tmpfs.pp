# mount certain volatile directories in memory
class ocf_desktop::tmpfs {
  include ocf::tmpfs

  mount {
    '/home':
      device  => 'tmpfs',
      fstype  => 'tmpfs',
      options => 'mode=0755,noatime,nodev,nosuid';
    '/var/tmp':
      device  => 'tmpfs',
      fstype  => 'tmpfs',
      options => 'noatime,nodev,nosuid'
  }

  # create pam_mkhomedir profile
  file { '/usr/share/pam-configs/mkhomedir':
    source => 'puppet:///modules/ocf_desktop/pam/mkhomedir',
    notify => Exec['pam-auth-update']
  }

  # on-disk temporary directories mounted at ~/tmp
  file {
    '/var/local/tmp':
      ensure => directory,
      mode   => '0755';

    '/usr/local/sbin/clean-temp-files':
      source  => 'puppet:///modules/ocf_desktop/clean-temp-files',
      mode    => '0755';
  }

  cron { 'clean-temp-files':
    command => '/usr/local/sbin/clean-temp-files',
    special => 'absent',
    hour    => '9',
    minute  => '5',
    require => File['/usr/local/sbin/clean-temp-files'];
  }
}
