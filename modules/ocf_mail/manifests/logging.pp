class ocf_mail::logging {
  file {
    # outgoing nomail logging
    '/var/mail/nomail':
      ensure  => directory,
      mode    => '0755',
      owner   => ocfmail,
      group   => ocfmail;
    '/etc/logrotate.d/nomail':
      ensure  => file,
      source  => 'puppet:///modules/ocf_mail/site_ocf/logrotate/nomail';
  }

  ocf::munin::plugin { 'mails-past-hour':
    source => 'puppet:///modules/ocf_mail/site_ocf/munin/mails-past-hour',
    user   => root,
  }
}
