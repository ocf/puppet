class ocf::common::rootpw {
  user { 'root':
    password => file("/opt/puppet/private/$hostname/rootpw")
  }
}
