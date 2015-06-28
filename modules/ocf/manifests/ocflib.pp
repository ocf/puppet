class ocf::ocflib {
  # TODO: remove this after jessie upgrade
  if $::lsbdistcodename == 'jessie' {
    package { 'python3-ocflib':; }
  } else {
    $deps = ['libcrack2-dev']

    package {
      'ocflib':
        ensure   => latest,
        provider => pip3,
        require  => Package[$deps];

      $deps:;
    }
  }
}
