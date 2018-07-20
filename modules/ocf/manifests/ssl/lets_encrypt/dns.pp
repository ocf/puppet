define ocf::ssl::lets_encrypt::dns(
  Array[String] $domains = [$::fqdn],
) {
  require ocf::ssl::lets_encrypt::dns_common

  concat::fragment { $title:
    target  => '/var/lib/lets-encrypt/domains.txt',
    content => "${join($domains, ' ')} > ${title}",
  }

  # Only run the dehydrated command to renew the cert if it is old enough (30
  # days = 2592000 seconds left until it expires). dehydrated does this check
  # itself, but this should help with puppet error spam a bit (for instance
  # if Let's Encrypt is down for any reason) and mean that services can
  # subscribe to this class to reload after new certs are obtained since this
  # won't refresh unless dehydrated is re-run for some reason.
  exec { "check ${title} cert expiration":
    command => '/bin/true',
    unless  => "openssl x509 -checkend 2592000 -noout -in /var/lib/lets-encrypt/certs/${title}/cert.pem",
    user    => ocfletsencrypt,
  } ~>
  exec { "obtain ${title} cert":
    # This exec can be notified to get it to run dehydrated again, even if the
    # cert will not expire soon.
    command     => '/usr/bin/dehydrated --cron --privkey /etc/ssl/lets-encrypt/le-account.key',
    user        => ocfletsencrypt,
    refreshonly => true,
    require     => Package['dehydrated-hook-ddns-tsig'],
    subscribe   => [
      Concat['/var/lib/lets-encrypt/domains.txt'],
      File['/etc/dehydrated/config'],
      File['/etc/dehydrated/dehydrated-hook-ddns-tsig.conf'],
      File['/etc/ssl/lets-encrypt/le-account.key'],
    ],
  } ~>
  file {
    # This is done to clean up permissions on certs after they are obtained
    # since this is not currently configurable through dehydrated:
    # https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=854431 and
    # https://github.com/lukas2511/dehydrated/issues/544
    "/var/lib/lets-encrypt/certs/${title}":
      ensure  => directory,
      owner   => ocfletsencrypt,
      group   => ssl-cert,
      mode    => '0640',
      recurse => true,
      require => [Package['ssl-cert'], File['/var/lib/lets-encrypt/certs']],
  }
}
