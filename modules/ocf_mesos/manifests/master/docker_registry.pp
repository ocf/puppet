class ocf_mesos::master::docker_registry {
  include ocf_ssl
  include ocf::packages::docker

  ocf::systemd::service { 'docker-registry':
    content => "[Unit]
Description=Mesos Docker registry
Requires=network-online.target
After=docker.service

[Service]
User=root
ExecStart=/usr/bin/docker run --rm -v /etc/ssl/certs/incommon-intermediate.crt:/etc/ssl/certs/incommon-intermediate.crt -v /etc/ssl/private/${::fqdn}.key:/etc/ssl/private/private.key -v /etc/ssl/private/${::fqdn}.bundle:/etc/ssl/private/private.crt -v /var/lib/registry:/var/lib/registry -p 5000:5000 --name registry -e REGISTRY_HTTP_TLS_CERTIFICATE=/etc/ssl/private/private.crt -e REGISTRY_HTTP_TLS_KEY=/etc/ssl/private/private.key registry:2
Restart=always

[Install]
WantedBy=multi-user.target",
    require => [
      Package['docker.io'],
      File['/var/lib/registry'],
    ],
  }

  file { '/var/lib/registry':
    ensure => directory,
  }
}
