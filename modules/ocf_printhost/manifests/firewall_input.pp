# firewall input rules for ocf_printhost,
#   http (80), https (443), ipp (631 t/u)
class ocf_printhost::firewall_input {
  include ocf::firewall::allow_http

  ocf::firewall::firewall46 {
    '103 allow ipp':
      opts => {
        chain  => 'PUPPET-INPUT',
        proto  => ['tcp', 'udp'],
        dport  => 631,
        action => 'accept',
      };
  }
}
