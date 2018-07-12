class ocf::ssl::lets_encrypt::dns_common {
  ocf::repackage { 'dehydrated':
    backport_on => ['jessie', 'stretch'],
  }
  package { 'dehydrated-hook-ddns-tsig':
    require => Package['dehydrated'],
  }

  $letsencrypt_ddns_key = assert_type(Stdlib::Base64, hiera('letsencrypt::ddns::key'))

  file {
    '/var/lib/lets-encrypt/certs':
      ensure  => directory,
      owner   => ocfletsencrypt,
      group   => ssl-cert,
      require => Package['ssl-cert'];

    '/etc/dehydrated/config':
      source  => 'puppet:///modules/ocf/ssl/dehydrated-config',
      require => Package['dehydrated'];

    '/etc/dehydrated/dehydrated-hook-ddns-tsig.conf':
      content   => template('ocf/ssl/dehydrated-hook-ddns-tsig.conf.erb'),
      show_diff => false,
      require   => Package['dehydrated-hook-ddns-tsig'];
  }

  # https://github.com/lukas2511/dehydrated/blob/master/docs/domains_txt.md
  concat { '/var/lib/lets-encrypt/domains.txt':
    ensure         => present,
    ensure_newline => true,
    owner          => ocfletsencrypt,
    group          => ssl-cert,
  }
}
