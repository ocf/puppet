# Common SSL settings for all sites.
class ocf_www::ssl {
  if defined($::http_protocols) {
    apache::custom_config { 'ocf-ssl':
      content => "
        SSLProtocol ${::ssl_protocols}
        SSLCipherSuite ${::ssl_ciphersuite}
        Protocols ${::http_protocols}
      ",
    }
  } else {
    apache::custom_config { 'ocf-ssl':
      content => "
        SSLProtocol ${::ssl_protocols}
        SSLCipherSuite ${::ssl_ciphersuite}
      ",
    }
  }
}
