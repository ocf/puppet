# firewall input rule to allow http and https
class ocf::firewall::allow_http {
  ocf::firewall::firewall46 {
    '100 allow http and https':
      opts => {
        chain  => 'PUPPET-INPUT',
        proto  => 'tcp',
        dport  => [80, 443],
        action => 'accept',
      };
  }
}
