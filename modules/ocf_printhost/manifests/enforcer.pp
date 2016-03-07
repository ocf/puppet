class ocf_printhost::enforcer {
  # enforcer will probably depend on cups-tea4cups in the future
  package { ['cups-tea4cups', 'enforcer']: }

  file { '/etc/cups/tea4cups.conf':
    source  => 'puppet:///modules/ocf_printhost/cups/tea4cups.conf',
    require => Package['cups-tea4cups', 'enforcer'],
    notify  => Service['cups'];
  }
}
