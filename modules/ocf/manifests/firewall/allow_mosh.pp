# firewall input rule to allow mosh
class ocf::firewall::allow_mosh {
  ocf::firewall::firewall46 {
    '101 accept all mosh':
      opts => {
        chain  => 'PUPPET-INPUT',
        proto  => 'udp',
        dport  => '60000-60999',
        action => 'accept',
      };
  }
}
