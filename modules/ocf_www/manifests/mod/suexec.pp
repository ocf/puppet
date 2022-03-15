class ocf_www::mod::suexec {
  include apache::mod::suexec

  package {
    'apache2-suexec-ocf':;
  }

  alternatives { 'suexec':
    path    => '/usr/lib/apache2/suexec-ocf',
    require => Package['apache2-suexec-ocf'],
  }
}
