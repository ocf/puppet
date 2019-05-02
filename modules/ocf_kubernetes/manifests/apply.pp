define ocf_kubernetes::apply(
  $target,
  $config = '/etc/kubernetes/admin.conf',
) {

  exec { "kubectl-apply-${title}":
    environment => ["KUBECONFIG=${config}"],
    command     => "kubectl apply -f ${target}",
    require     => [Package['kubectl'], Class['kubernetes']],
  }
}
