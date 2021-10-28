class ocf::packages::kubernetes::apt {
  apt::key { 'kubernetes':
    id      => '7F92E05B31093BEF5A3C2D38FEEA9169307EA071',
    source  => 'https://packages.cloud.google.com/apt/doc/apt-key.gpg',
    require => Package['apt-transport-https'],
  }
  apt::source { 'kubernetes':
    location => 'https://apt.kubernetes.io',
    repos    => 'main',
    # NOTE: we can't use kubernetes-stretch because kubelet isn't included.
    release  => 'kubernetes-xenial',
  }

  # This comes from the local variable of the same name in
  # github.com/puppetlabs/puppetlabs-kubernetes/blob/master/manifests/packages.pp,
  # which unfortunately is not exposed.
  $kube_packages = ['kubelet', 'kubectl', 'kubeadm']
  $kube_package_version = lookup('kubernetes::kubernetes_package_version')

  # Pin each package in $kube_packages to the hiera-specified version,
  # so they won't get upgraded automatically by apt-dater.
  apt::pin { 'kubernetes':
    packages    => $kube_packages,
    version     => $kube_package_version,
    priority    => 1001,
    explanation => "Pin kubernetes packages to the hiera-specified version so they won't get upgraded automatically by apt-dater",
  }
}
