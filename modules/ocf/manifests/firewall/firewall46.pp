define ocf::firewall::firewall46($opts,) {
  # Ruby's Resolv class doesn't think it should resolve IPv6 addresses if the
  # local host doesn't have a public IPv6 address. Thus we only try to apply
  # IPv6 firewall rules here if the host already has an IPv6 address.
  $providers = $::ipaddress6 ? {
    undef     => ['iptables'],
    /^fe80::/ => ['iptables'],
    default   => ['iptables', 'ip6tables'],
  }

  firewall_multi { "${title} (firewall_multi)":
    provider  => $providers,
    require   => $require,
    subscribe => $subscribe,
    before    => $before,
    notify    => $notify,
    *         => $opts,
  }
}
