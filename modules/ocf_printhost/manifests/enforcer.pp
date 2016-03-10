class ocf_printhost::enforcer {
  # enforcer will probably depend on cups-tea4cups in the future
  package { ['cups-tea4cups', 'enforcer']: }

  file {
    '/etc/cups/tea4cups.conf':
      source  => 'puppet:///modules/ocf_printhost/cups/tea4cups.conf',
      require => Package['cups-tea4cups', 'enforcer'];
    '/opt/share/enforcer':
      ensure => directory,
      mode   => '0500';
    '/opt/share/enforcer/enforcer.conf':
      source => 'puppet:///private/enforcer/enforcer.conf';
  }
}
