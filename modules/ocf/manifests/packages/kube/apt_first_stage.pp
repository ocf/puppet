# Don't import this, use ocf::packages::kube::apt instead.
# This is a dependency order hack.
class ocf::packages::kube::apt_first_stage {
  apt::key { 'kubernetes':
      id      => '7F92E05B31093BEF5A3C2D38FEEA9169307EA071',
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

  apt::key { 'crio repo key':
    id     => '2472D6D0D2F66AF87ABA8DA34D64390375060AA4',
    # the key is the same for both
    source => 'https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/Debian_${::operatingsystemmajrelease}/Release.key';
  }

  $is_dev = $::hostname in lookup('kube_dev::controller_nodes')
  $kube_prefix = if $is_dev { 'kube_dev' } else { 'kube' }
  $kube_version = lookup("${kube_prefix}::kubernetes_version")
  $split_version = split($kube_version, '.')
  $crio_version = $split_version[0] + '.' + $split_version[1]

  # for packages: cri-o cri-o-runc
  apt::source { 'crio':
      architecture => 'amd64',
      location     => "http://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable:/cri-o:/${crio_version}/Debian_${::operatingsystemmajrelease}/",
      repos        => '/',
      require      => Apt::Key['crio repo key'],
  }
  apt::source { 'libcontainers':
      architecture => 'amd64',
      location     => 'https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/Debian_${::operatingsystemmajrelease}/',
      repos        => '/',
      require      => Apt::Key['crio repo key'],
  }
}
