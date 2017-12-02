# firewall input rules for ocf_mirrors,
#   allow ssh (22), http (80), https (443), ftp (21), rsync (873)
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

    '105 allow rsync':
      opts => {
        chain  => 'PUPPET-INPUT',
        proto  => 'tcp',
        dport  => 873,
        action => 'accept',
      };
  }
}
