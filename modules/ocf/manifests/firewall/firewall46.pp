define ocf::firewall::firewall46($opts,) {
  firewall { "${title} (IPv4)":
    require   => $require,
    subscribe => $subscribe,
    before    => $before,
    notify    => $notify,
    *         => $opts,
  }

  # Ruby's Resolv class doesn't think it should resolve IPv6 addresses if the
  # local host doesn't have a public IPv6 address. Thus we only try to apply
  # IPv6 firewall rules here if the host already has an IPv6 address.
  if $::ipaddress6 and $::ipaddress6 !~ /^fe80::/ {
    firewall { "${title} (IPv6)":
      provider  => 'ip6tables',
      require   => $require,
      subscribe => $subscribe,
      before    => $before,
      notify    => $notify,
      *         => $opts,
    }
  }
}
