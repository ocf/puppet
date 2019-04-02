class ocf::packages::kubernetes::apt {
  apt::key { 'kubernetes':
    id      => '54A647F9048D5688D7DA2ABE6A030B21BA07F4FB',
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
  # Pins each package in $kube_packages to the hiera-specified version,
  # so it won't get upgraded automatically by apt.
  file { '/etc/apt/preferences.d/kubernetes.pref':
    ensure  => file,
    content => template('ocf/apt/kubernetes-pin.pref.erb'),
  }
}
