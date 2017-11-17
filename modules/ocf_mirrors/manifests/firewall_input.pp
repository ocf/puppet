# firewall input rules for ocf_mirrors,
#   allow ssh (22), http (80), https (443), ftp (21), rsync (873)
class ocf_mirrors::firewall_input {

  ocf::firewall::firewall46 {

    '101 allow ssh':
      opts => {
        'chain'  => 'PUPPET-INPUT',
        'proto'  => 'tcp',
        'dport'  => 'ssh',
        'action' => 'accept',
      };


    '102 allow http ':
      opts => {
        'chain'  => 'PUPPET-INPUT',
        'proto'  => 'tcp',
        'dport'  => 'http',
        'action' => 'accept',
      };

    '103 allow https':
      opts => {
        'chain'  => 'PUPPET-INPUT',
        'proto'  => 'tcp',
        'dport'  => 'https',
        'action' => 'accept',
      };

    '104 allow ftp':
      opts => {
        'chain'  => 'PUPPET-INPUT',
        'proto'  => 'tcp',
        'dport'  => 'ftp',
        'action' => 'accept',
      };

    '105 allow rsync':
      opts => {
        'chain'  => 'PUPPET-INPUT',
        'proto'  => 'tcp',
        'dport'  => 'rsync',
        'action' => 'accept',
      };
  }
}
