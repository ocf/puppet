class ocf_apphost {
  include ocf::extrapackages
  include ocf::hostkeys
  include ocf_apphost::proxy
  include ocf_apphost::ssl

  class { 'ocf::nfs':
    cron => true;
  }

  # enable a persistent per-user systemd for all ocfdev users
  file { '/var/lib/systemd/linger':
    ensure  => directory,
    # This makes sure only ocfdev users get per-user systemd.
    recurse => true,
    purge   => true;
  }
  $devs = split($::ocf_dev, ',')
  $devs.each |$user| {
    file { "/var/lib/systemd/linger/${user}":
      ensure => file;
    }
  }

  # create directory for per-user systemd logs
  file { '/var/log/journal':
    ensure => directory;
  }

  file {
    '/srv/apps':
      ensure => directory,
      mode   => '0755';
  }
}
