# TODO: Separate out this file into the http and dns versions, since they can't
# overlap anyways due to resource duplicate declaration problems
define ocf::ssl::lets_encrypt(
  Array[String] $domains = [$::fqdn],
  Enum['http', 'dns'] $challenge_type = 'dns',
) {
  if $challenge_type == 'http' {
    package { ['acme-tiny', 'python3-openssl']:; }

    file {
      [
        '/var/lib/lets-encrypt/.well-known',
        '/var/lib/lets-encrypt/.well-known/acme-challenge',
      ]:
        ensure  => directory,
        owner   => ocfletsencrypt,
        group   => ssl-cert,
        require => Package['ssl-cert'];

      '/usr/local/bin/ocf-lets-encrypt':
        source  => 'puppet:///modules/ocf/ssl/ocf-lets-encrypt',
        mode    => '0755',
        require => Package['acme-tiny', 'python3-openssl'];
    }
  } else {
    ocf::repackage { 'dehydrated':
      backport_on => ['jessie', 'stretch'],
    }
    package { 'dehydrated-hook-ddns-tsig':
      require => Ocf::Repackage['dehydrated'],
    }

    $letsencrypt_ddns_key = assert_type(Stdlib::Base64, hiera('letsencrypt::ddns::key'))

    # TODO: Move these somewhere else so this defined resource can be used
    # multiple times without issues with resources colliding
    file {
      '/var/lib/lets-encrypt/certs':
        ensure  => directory,
        owner   => ocfletsencrypt,
        group   => ssl-cert,
        mode    => '0640',
        recurse => true,
        require => [Package['ssl-cert'], Exec[$title]];

      # https://github.com/lukas2511/dehydrated/blob/master/docs/domains_txt.md
      '/var/lib/lets-encrypt/domains.txt':
        owner   => ocfletsencrypt,
        group   => ssl-cert,
        content => "${join($domains, ' ')} > ${title}",
        notify  => Exec[$title];

      '/etc/dehydrated/config':
        source  => 'puppet:///modules/ocf/ssl/dehydrated-config',
        require => Package['dehydrated'],
        notify  => Exec[$title];

      '/etc/dehydrated/dehydrated-hook-ddns-tsig.conf':
        content   => template('ocf/ssl/dehydrated-hook-ddns-tsig.conf.erb'),
        show_diff => false,
        require   => Package['dehydrated-hook-ddns-tsig'],
        notify    => Exec[$title];
    }

    # Only run the dehydrated command to renew the cert if it is old enough (30
    # days = 2592000 seconds left until it expires). dehydrated does this check
    # itself, but this should help with puppet error spam a bit (for instance
    # if Let's Encrypt is down for any reason) and mean that services can
    # subscribe to this resource to refresh after new certs are obtained.
    exec { "${title}_check_expiration":
      command => '/bin/true',
      unless  => "openssl x509 -checkend 2592000 -noout -in /var/lib/lets-encrypt/certs/${title}/cert.pem",
      user    => ocfletsencrypt,
      notify  => Exec[$title],
    }

    # This exec can be notified to get it to check anyway, for instance, if the
    # dehydrated config changes, or the domain list changes then this should
    # run again, even if the cert will not expire soon.
    exec { $title:
      command     => '/usr/bin/dehydrated --cron --privkey /etc/ssl/lets-encrypt/le-account.key',
      user        => ocfletsencrypt,
      refreshonly => true,
      require     => [
        Package['dehydrated-hook-ddns-tsig'],
        File['/var/lib/lets-encrypt/domains.txt'],
        File['/etc/dehydrated/config'],
        File['/etc/dehydrated/dehydrated-hook-ddns-tsig.conf'],
        File['/etc/ssl/lets-encrypt/le-account.key'],
      ],
    }
  }
}
