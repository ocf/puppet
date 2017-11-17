# firewall input rules for ocf_mail, allow submission (587), allow smtp (25)
class ocf_mail::firewall_input {
  ocf::firewall::firewall46 {
    '101 allow submission':
      opts => {
        'chain'  => 'PUPPET-INPUT',
        'proto'  => 'tcp',
        'dport'  => 'submission',
        'action' => 'accept',
      };

    '102 allow smtp':
      opts => {
        'chain'  => 'PUPPET-INPUT',
        'proto'  => 'tcp',
        'dport'  => 'smtp',
        'action' => 'accept',
      };
  }
}
