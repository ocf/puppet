class common::ocflib {
  $deps = ['libcrack2-dev']

  package {
    # Require requests explicitly due to bug in pip preventing installation as
    # a dependency. Can be removed after the next requests release (> 2.5.1).
    #
    # https://github.com/kennethreitz/requests/pull/2420
    'requests':
      ensure   => latest,
      provider => pip3;

    'ocflib':
      ensure   => latest,
      provider => pip3,
      require  => [Package[$deps], Package['requests']];

    $deps:;
  }
}
