class ocf_www::mod::remoteip {
  include apache::mod::remoteip

  apache::custom_config { 'remoteip':
    content => '
      RemoteIPHeader X-Forwarded-For
      RemoteIPInternalProxy 127.0.0.1
    ',
  }
}
