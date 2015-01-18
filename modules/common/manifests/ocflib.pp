class common::ocflib {
  package { 'ocflib':
    ensure   => latest,
    provider => pip3;
  }
}
