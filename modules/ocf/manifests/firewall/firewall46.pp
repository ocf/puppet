define ocf::firewall::firewall46($opts,){
  firewall{"${title} (IPv4)":
    * => $opts,
  }
  firewall{"${title} (IPv6)":
              * => $opts,
    provider    => 'ip6tables',
  }
}
