# Don't import this, use ocf::packages::kube::apt instead.
# This is a dependency order hack.
class ocf::packages::kube::apt_first_stage {
  apt::key { 'kubernetes':
      id      => '54A647F9048D5688D7DA2ABE6A030B21BA07F4FB',
      source  => 'https://packages.cloud.google.com/apt/doc/apt-key.gpg',
      require => Package['apt-transport-https'],
  }

  apt::source { 'kubernetes':
      location => 'https://apt.kubernetes.io',
      repos    => 'main',
      # NOTE: Normally you really don't want to include packages for other
      # OS versions. This is beacuse other OS versions have different versions
      # of libraries that packages expect to dynamically link to. But kubernetes
      # is written in Go, which doesn't do dynamic linking. So this is safe to
      # pull.
      release  => 'kubernetes-xenial',
  }
}
