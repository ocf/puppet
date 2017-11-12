define ocf::firewall::firewall46($opts,) {
  firewall { "${title} (IPv4)":
    require   => $require,
    subscribe => $subscribe,
    before    => $before,
    notify    => $notify,
    *         => $opts,
  }

  firewall { "${title} (IPv6)":
    provider  => 'ip6tables',
    require   => $require,
    subscribe => $subscribe,
    before    => $before,
    notify    => $notify,
    *         => $opts,
  }
}
