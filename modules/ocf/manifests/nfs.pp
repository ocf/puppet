class ocf::nfs($cron = false, $web = false) {
  package { 'nfs-common': }

  # Create directories to mount NFS shares on
  # Directory permissions are set by NFS share when mounted
  # Use exec instead of file so that permissions are not managed
  exec {
    'mkdir /home':
      creates => '/home';
    'mkdir /services':
      creates => '/services';
  }

  # Mount NFS shares
  mount {
    '/home':
      device  => 'homes:/home',
      fstype  => 'nfs4',
      options => 'rw,bg,noatime,nodev,nosuid',
      require => Exec['mkdir /home'];
    '/services':
      device  => 'services:/services',
      fstype  => 'nfs4',
      options => 'rw,bg,noatime,nodev,nosuid',
      require => Exec['mkdir /services'];
  }

  if $cron {
    file {
      '/var/spool/cron/crontabs':
        ensure => link,
        target => "/services/crontabs/${::hostname}",
        force  => true;
    }
  }

  if $web {
    exec {
    'mkdir /opt/httpd':
      creates => '/opt/httpd';
    }

    mount {
    '/opt/httpd':
      device  => 'www:/',
      fstype  => 'nfs4',
      options => 'ro,bg,noatime,nodev,noexec,nosuid',
      require => Exec['mkdir /opt/httpd'];
    }
  }
}
