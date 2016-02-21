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

  ocf::systemd::service {
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
      ];
  }
}
