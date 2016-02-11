class ocf_www::mod::suexec {
  include apache::mod::suexec

  package {
    'apache2-suexec-ocf':;
  }

  file { '/etc/alternatives/suexec':
    ensure => link,
    target => '/usr/lib/apache2/suexec-ocf',
    require => Package['apache2-suexec-ocf'],
  }
}
