class ocf::nfs($pykota = false, $cron = false) {
  # Create directories to mount NFS shares on
  # Directory permissions are set by NFS share when mounted
  # Use exec instead of file so that permissions are not managed
  exec {
    'mkdir /home':
      creates => '/home';
    'mkdir /opt/ocf':
      creates => '/opt/ocf';
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
    '/opt/ocf':
      device  => 'opt:/i686-real',
      fstype  => 'nfs4',
      options => 'ro,bg,noatime,nodev',
      require => Exec['mkdir /opt/ocf'];
    '/services':
      device  => 'services:/services',
      fstype  => 'nfs4',
      options => 'rw,bg,noatime,nodev,nosuid',
      require => Exec['mkdir /services'];
  }

  if $pykota {
    exec {
      'mkdir /etc/pykota':
        creates => '/etc/pykota';
      'mkdir /opt/httpd':
        creates => '/opt/httpd';
    }

    mount {
      '/etc/pykota':
        device  => 'printhost:/',
        fstype  => 'nfs4',
        options => 'ro,bg,noatime,nodev,noexec,nosuid',
        require => Exec['mkdir /etc/pykota'];
      '/opt/httpd':
        device  => 'www:/',
        fstype  => 'nfs4',
        options => 'ro,bg,noatime,nodev,noexec,nosuid',
        require => Exec['mkdir /opt/httpd'];
    }
  }

  if $cron {
    file {
      '/var/spool/cron/crontabs':
        ensure => link,
        target => "/services/crontabs/${::hostname}",
        force  => true;
    }
  }
}
