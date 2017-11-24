# firewall input rule to allow http and https
class ocf::firewall::allow_http {
  ocf::firewall::firewall46{
    '101 allow https':
      opts => {
        chain  => 'PUPPET-INPUT',
        proto  => 'tcp',
        dport  => 'https',
        action => 'accept',
      };

    '102 allow http':
      opts => {
        chain  => 'PUPPET-INPUT',
        proto  => 'tcp',
        dport  => 'http',
        action => 'accept',
      };
  }
}
