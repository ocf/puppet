# Common SSL settings for all sites.
class ocf_www::ssl {
  apache::custom_config { 'ocf-ssl':
    content => "
      SSLProtocol ${::ssl_protocols}
      SSLCipherSuite ${::ssl_ciphersuite}
    ",
  }
}
