# firewall input rule to allow ssh
class ocf::firewall::allow_ssh {
  ocf::firewall::firewall46 {
    '101 accept all ssh':
      opts => {
        chain  => 'PUPPET-INPUT',
        proto  => 'tcp',
        dport  => 22,
        action => 'accept',
      };
  }
}
