# Firewall input rules for ocf_mirrors
class ocf_mirrors::firewall_input {
  include ocf::firewall::allow_ssh
  include ocf::firewall::allow_http

  ocf::firewall::firewall46 {
    '104 allow ftp':
      opts => {
        chain  => 'PUPPET-INPUT',
        proto  => 'tcp',
        dport  => 21,
        action => 'accept',
        };

    '104 allow ftp passive data connections':
      opts => {
        chain  => 'PUPPET-INPUT',
        proto  => 'tcp',
        dport  => '10000-11000',
        action => 'accept',
      };

    '105 allow rsync':
      opts => {
        chain  => 'PUPPET-INPUT',
        proto  => 'tcp',
        dport  => 873,
        action => 'accept',
      };
  }
}
