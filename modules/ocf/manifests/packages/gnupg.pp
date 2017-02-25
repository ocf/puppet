class ocf::packages::gnupg {
  if $::lsbdistcodename != 'jessie' {
    package { 'dirmngr':; }
  }
}
