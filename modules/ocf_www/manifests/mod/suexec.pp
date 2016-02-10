class ocf_www::mod::suexec {
  include apache::mod::suexec

  package {
    'apache2-suexec-pristine':;

    ['apache2-suexec', 'apache2-suexec-custom']:
      ensure => purged;
  }
}
