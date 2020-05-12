# Set up Apache log permissions and NFS exports so that users can see web logs
# from the login server.
class ocf_www::logging {
  # NFS host and log permissions
  package { 'nfs-kernel-server':; }
  service { 'nfs-kernel-server':
    require => Package['nfs-kernel-server'],
  }

  # log outbound requests
  firewall_multi {
    '101 log outbound request on death (v4)':
        provider    => 'iptables',
        chain       => 'PUPPET-OUTPUT',
        outiface    => '! lo',
        jump        => 'LOG',
        destination => '! 169.229.226.0/24',
        log_prefix  => '[iptables] ',
        log_level   => 7,
        log_uid     => true;

    '101 log outbound request on death (v6)':
        provider    => 'ip6tables',
        chain       => 'PUPPET-OUTPUT',
        outiface    => '! lo',
        jump        => 'LOG',
        destination => '! 2607:f140:8801::/48',
        log_prefix  => '[iptables] ',
        log_level   => 7,
        log_uid     => true;
  }

  file {
    '/etc/exports':
      source  => 'puppet:///modules/ocf_www/exports',
      require => Package['nfs-kernel-server'],
      notify  => Service['nfs-kernel-server'];

    # Users need to be able to read files in this directory.
    '/var/log/apache2':
      mode    => '0755',
      require => Package['httpd'];

    # Redirect iptables logs to different file
    '/etc/rsyslog.d/iptables-log.conf':
      source  => 'puppet:///modules/ocf_www/iptables-log.conf',
      require => Package['rsyslog'],
      notify  => Service['rsyslog'],
  }

  # logrotate config
  package { 'logrotate':; }
  augeas { 'apache-logrotate':
    lens    => 'Logrotate.lns',
    incl    => '/etc/logrotate.d/apache2',
    changes => [
      "set rule[file='/var/log/apache2/*.log']/create/mode 644",
      "set rule[file='/var/log/apache2/*.log']/ifempty ifempty",
    ],
    require => Package['logrotate', 'httpd'],
    notify  => Exec['apache2-logrotate-once'],
  }

  # If we change the logrotate permissions, we should force a rotate once so
  # that the latest logs are readable.
  exec { 'apache2-logrotate-once':
    command     => '/usr/sbin/logrotate -fv /etc/logrotate.d/apache2',
    refreshonly => true,
  }

  # Log vhost name in error log
  apache::custom_config { 'error_log':
    content => "ErrorLogFormat \"%v: [%t] [%l] [pid %P] %F: %E: [client %a] %M\"\n",
  }

  include ocf::firewall::nfs
}
