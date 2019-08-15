# Firewall input rules for ocf_mirrors
class ocf_mirrors::firewall_input {
  include ocf::firewall::allow_ssh
  include ocf::firewall::allow_web

  ocf::firewall::firewall46 {
    '105 allow rsync':
      opts => {
        chain  => 'PUPPET-INPUT',
        proto  => 'tcp',
        dport  => 873,
        action => 'accept',
      };
  }
}
