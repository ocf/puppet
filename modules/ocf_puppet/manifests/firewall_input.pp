# firewall input rules for ocf_puppet,
#   allow puppet (8140 t)
class ocf_puppet::firewall_input {
  ocf::firewall::firewall46 {
    '101 allow puppet':
      opts => {
        'chain'  => 'PUPPET-INPUT',
        'proto'  => 'tcp',
        'dport'  => 'puppet',
        'action' => 'accept',
      };
  }
}
