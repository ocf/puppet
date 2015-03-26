class ocf::ocflib {
  $deps = ['libcrack2-dev']

  package {
    'ocflib':
      ensure   => latest,
      provider => pip3,
      require  => Package[$deps];

    $deps:;
  }
}
