class ocf_www::mod::security {
  class { '::apache::mod::security':
    # Disable OPTIONS requests, originally due to CVE-2017-9798
    allowed_methods => 'GET HEAD POST',
  }
}
