class ocf_mail::logging {
  file {
    # outgoing nomail logging
    '/var/mail/nomail':
      ensure => directory,
      mode   => '0755',
      owner  => ocfmail,
      group  => ocfmail;
    '/etc/logrotate.d/nomail':
      ensure => file,
      source => 'puppet:///modules/ocf_mail/site_ocf/logrotate/nomail';
  }
}
