# firewall input rule to allow mosh (and ssh)
class ocf::firewall::allow_mosh {
  include ocf::firewall::allow_ssh

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
