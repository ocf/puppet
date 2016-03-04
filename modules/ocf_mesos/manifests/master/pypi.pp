class ocf_mesos::master::pypi {
  user { 'ocfpypi':
    home   => '/srv/linux-wheels',
    groups => ['sys'],
    shell  => '/bin/false',
  }

  file { ['/srv/linux-wheels', '/srv/linux-wheels/wheelhouse']:
    ensure  => directory,
    owner   => ocfpypi,
    group   => ocfpypi,
    require => User['ocfpypi'],
  }

  # TODO: this is a terrible way to deploy a Python service
  vcsrepo { '/srv/linux-wheels/linux-wheels':
    ensure   => latest,
    user     => ocfpypi,
    provider => git,
    revision => 'master',
    source   => 'https://github.com/chriskuehl/linux-wheels.git',
    notify   => Ocf::Systemd::Service['pypi-upload-handler'],
  }

  ocf::systemd::service {
    # TODO: this requires manual vhost creation
    'pypi-server':
      content => "[Unit]
Description=PyPI Server
Requires=network-online.target

[Service]
User=ocfpypi
ExecStart=/srv/linux-wheels/pypi-server/bin/pypi-server /srv/linux-wheels/wheelhouse
Restart=always

[Install]
WantedBy=multi-user.target",
      require => [
        User['ocfpypi'],
      ];

    'pypi-upload-handler':
      content => "[Unit]
Description=PyPI Upload Handler
Requires=network-online.target

[Service]
WorkingDirectory=/srv/linux-wheels/linux-wheels/
User=ocfpypi
ExecStart=/usr/bin/make gunicorn
Restart=always

[Install]
WantedBy=multi-user.target",
      require => [
        User['ocfpypi'],
        Vcsrepo['/srv/linux-wheels/linux-wheels'],
      ];
  }
}
