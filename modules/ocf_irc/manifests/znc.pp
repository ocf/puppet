# A minimal ZNC installation
# All extra configuration is managed by web interface and kept in backups
class ocf_irc::znc {
  package { 'znc': }

  user { 'ocfznc':
    comment => 'IRC Bouncer Server',
    groups  => [ssl-cert],
    home    => '/var/lib/znc',
    shell   => '/bin/false',
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
    subscribe => Ocf::Ssl::Bundle[$::fqdn],
  }
}
