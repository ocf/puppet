class common::rootpw {
  user { 'root':
    password => file("/opt/puppet/shares/private/${::hostname}/rootpw")
  }
}
