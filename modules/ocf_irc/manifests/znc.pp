# A minimal ZNC installation
# All extra configuration is managed by web interface and kept in backups
class ocf_irc::znc {
  package { 'znc': }

  ocf::systemuser { 'ocfznc':
    opts    => {
      comment => 'IRC Bouncer Server',
      home    => '/var/lib/znc',
      shell   => '/bin/false',
      groups  => ['ssl-cert'],
    },
    require => Package['ssl-cert'],
  }

  file {
    '/var/lib/znc':
      ensure  => directory,
      owner   => ocfznc,
      group   => ocfznc,
      mode    => '0700',
      require => User['ocfznc'];

    '/var/lib/znc/znc.pem':
      ensure => link,
      group  => ocfznc,
      owner  => ocfznc,
      target => "/etc/ssl/private/${::fqdn}.pem";
  }

  ocf::systemd::service { 'znc':
    source    => 'puppet:///modules/ocf_irc/znc.service',
    require   => [
      Package['znc'],
      File['/var/lib/znc'],
      File['/var/lib/znc/znc.pem'],
    ],
    subscribe => Class['ocf::ssl::default'],
  }
}
