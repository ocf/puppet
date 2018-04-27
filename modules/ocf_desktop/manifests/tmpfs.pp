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

  # on-disk temporary directories mounted at ~/tmp
  file {
    '/var/local/tmp':
      ensure => directory,
      mode   => '0755';

    '/usr/local/sbin/clean-temp-files':
      source => 'puppet:///modules/ocf_desktop/clean-temp-files',
      mode   => '0755';
  }

  cron { 'clean-temp-files':
    command => '/usr/local/sbin/clean-temp-files',
    special => 'hourly',
    require => File['/usr/local/sbin/clean-temp-files'];
  }
}
