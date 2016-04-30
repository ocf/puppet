class ocf_printhost::enforcer {
  package { ['cups-tea4cups']: }

  file {
    '/etc/cups/tea4cups.conf':
      content => template('ocf_printhost/cups/tea4cups.conf.erb'),
      require => Package['cups-tea4cups'];
    '/usr/local/bin/enforcer':
      source  => 'puppet:///modules/ocf_printhost/enforcer',
      mode    => '0755';
    '/usr/local/bin/enforcer-pc':
      source  => 'puppet:///modules/ocf_printhost/enforcer-pc',
      mode    => '0755';
    '/opt/share/enforcer':
      ensure  => directory,
      mode    => '0500';
    '/opt/share/enforcer/enforcer.conf':
      source  => 'puppet:///private/enforcer/enforcer.conf';
  }
}
