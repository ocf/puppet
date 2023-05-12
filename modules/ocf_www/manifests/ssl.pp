# Common SSL settings for all sites.
class ocf_www::ssl {
  apache::custom_config { 'ocf-ssl':
    content => "
      SSLProtocol ${facts['ssl_protocols']}
      SSLCipherSuite ${facts['ssl_ciphersuite']}
    ",
  }
}
