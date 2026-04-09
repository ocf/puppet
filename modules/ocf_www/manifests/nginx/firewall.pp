# CR-soon oliverni: remove when nginx moves to 80/443
class ocf_www::nginx::firewall {
  ocf::firewall::firewall46 {
    '101 allow nginx test ports':
      opts => {
        chain  => 'PUPPET-INPUT',
        proto  => 'tcp',
        dport  => [8080, 8443],
        action => 'accept',
      };
  }
}
