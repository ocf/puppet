class ocf_apphost {
  include ocf::extrapackages
  include ocf::hostkeys
  include ocf::motd
  include proxy
  include ssl

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
  # TODO: use a foreach loop once we have the future parser
  ocf_apphost::systemd_linger { $devs:; }

  file {
    '/srv/apps':
      ensure => directory,
      mode   => '0755';
  }
}
