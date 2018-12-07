class ocf::packages::kubernetes::apt {
  apt::key { 'kubernetes':
    id      => '54A647F9048D5688D7DA2ABE6A030B21BA07F4FB',
    source  => 'https://packages.cloud.google.com/apt/doc/apt-key.gpg',
    require => Package['apt-transport-https'],
  }
  apt::source { 'kubernetes':
    location => 'https://apt.kubernetes.io',
    repos    => 'main',
    release  => 'kubernetes-stretch',
  }
}
