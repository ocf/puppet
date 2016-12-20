class ocf_www::mod::suexec {
  include apache::mod::suexec

  # TODO: Figure out what to do for stretch (this package isn't included,
  # and has been patched even for jessie)
  package {
    'apache2-suexec-ocf':;
  }

  file { '/etc/alternatives/suexec':
    ensure => link,
    target => '/usr/lib/apache2/suexec-ocf',
    require => Package['apache2-suexec-ocf'],
  }
}
