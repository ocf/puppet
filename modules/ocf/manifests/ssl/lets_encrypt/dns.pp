define ocf::ssl::lets_encrypt::dns(
  Array[String] $domains = [$::fqdn],
  String $owner = 'ocfletsencrypt',
  String $group = 'ssl-cert',
) {
  require ocf::ssl::lets_encrypt::dns_common

  concat::fragment { $title:
    target  => '/var/lib/lets-encrypt/domains.txt',
    content => "${join($domains, ' ')} > ${title}",
  }

  $parsed_cert_info = parsejson($::le_cert_info)

  $have_cert_info = $title in $parsed_cert_info
  if $have_cert_info {

    # if we have info about the current cert, we need to check to make sure that
    # the cert includes all domains, and that it is not close to expiring

    $cert_expires_soon = $parsed_cert_info[$title]['days_to_expiration'] < 30

    # we subtract out any domains that are in the cert, and see if any are left
    $cert_has_all_domains = ($domains - $parsed_cert_info[$title]['cert_names']) =~ Array[String, 0, 0]
  }

  exec { "obtain ${title} cert":
    # This exec can be notified to get it to run dehydrated again, even if the
    # cert will not expire soon.
    command     => '/usr/bin/dehydrated --cron --privkey /etc/ssl/lets-encrypt/le-account.key',
    user        => $owner,
    require     => Package['dehydrated-hook-ddns-tsig'],

    # Only run the dehydrated command to renew the cert if it is old enough, or
    # missing some domains. dehydrated does the former check itself, but this
    # should help with puppet error spam a bit (for instance if Let's Encrypt is
    # down for any reason) and mean that services can subscribe to this class to
    # reload after new certs are obtained since this won't refresh unless
    # dehydrated is re-run for some reason.

    refreshonly => $have_cert_info and !$cert_expires_soon and $cert_has_all_domains,

    # If we have new domains, the dehydrated config changes, or other related
    # files are updated, we need to re-run dehydrated anyway

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
      owner   => $owner,
      group   => $group,
      mode    => '0640',
      recurse => true,
      require => [Package['ssl-cert'], File['/var/lib/lets-encrypt/certs']],
  }
}
