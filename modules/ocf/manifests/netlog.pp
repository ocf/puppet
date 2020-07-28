# A class that can be used to log outbound network requests
class ocf::netlog {
  package { ['logrotate']:; }

  $ocf_ipv4_mask = lookup('ocf_ipv4_mask')
  $ocf_ipv6_mask = lookup('ocf_ipv6_mask')

  firewall_multi {
    default:
        chain      => 'PUPPET-OUTPUT',
        outiface   => '! lo',
        state      => ['NEW'],
        jump       => 'LOG',
        log_prefix => '[iptables-outbound] ',
        log_level  => 7,
        log_uid    => true;
    "101 log outbound request on ${::hostname} (v4)":
        provider    => 'iptables',
        destination => "! ${ocf_ipv4_mask}";
    "101 log outbound request on ${::hostname} (v6)":
        provider    => 'ip6tables',
        destination => "! ${ocf_ipv6_mask}";
  }

  file {
    # Redirect iptables logs to different file
    '/etc/rsyslog.d/iptables-log.conf':
      source  => 'puppet:///modules/ocf/netlog/iptables-log.conf',
      require => Package['rsyslog'],
      notify  => Service['rsyslog'];

    '/etc/logrotate.d/iptables':
      source  => 'puppet:///modules/ocf/netlog/iptables-logrotate',
      require => Package['logrotate', 'rsyslog'],
  }

}
