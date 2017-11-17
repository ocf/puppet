# firewall input rules for ocf_printhost,
#   http (80), https (443), ipp (631 t/u)
class ocf_printhost::firewall_input {

  ocf::firewall::firewall46 {

    '101 allow http ':
      opts => {
        'chain'  => 'PUPPET-INPUT',
        'proto'  => 'tcp',
        'dport'  => 'http',
        'action' => 'accept',
      };

    '102 allow https':
      opts => {
        'chain'  => 'PUPPET-INPUT',
        'proto'  => 'tcp',
        'dport'  => 'https',
        'action' => 'accept',
      };

    '103 allow ipp':
      opts => {
        'chain'  => 'PUPPET-INPUT',
        'proto'  => [ 'tcp', 'udp' ],
        'dport'  => 'ipp',
        'action' => 'accept',
      };
  }
}
