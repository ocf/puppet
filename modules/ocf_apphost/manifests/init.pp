class ocf_apphost {
  include ocf::extrapackages
  include ocf::hostkeys
  include ocf_apphost::proxy
  include ocf_apphost::lets_encrypt

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
  if $::ocf_dev {
    $devs = split($::ocf_dev, ',')
  } else {
    # ocf_dev is empty on the first run which causes a runtime error above
    $devs = []
  }
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
