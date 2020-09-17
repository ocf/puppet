class ocf::firewall::use_legacy {
  # Buster and greater use iptables-nft by default, but puppetlabs-firewall requires iptables-legacy
  # So we check if we are using iptables-nft, and if so, change it to iptables-legacy

  exec { 'update-alternatives --set iptables /usr/sbin/iptables-legacy':
    onlyif => "update-alternatives --query iptables | grep 'Value: /usr/sbin/iptables-nft'",
  }
  exec { 'update-alternatives --set ip6tables /usr/sbin/ip6tables-legacy':
    onlyif => "update-alternatives --query ip6tables | grep 'Value: /usr/sbin/ip6tables-nft'",
  }
}
