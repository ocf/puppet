define ocf_kubernetes::applyk(
  $target,
  $config = '/etc/kubernetes/admin.conf',
) {

  exec { "kubectl-apply-${title}":
    environment => ["KUBECONFIG=${config}"],
    command     => "kubectl apply -k ${target}",
    # only apply if there are actually new changes, to avoid spam
    unless      => "kubectl diff -k ${target}",
    require     => Package['kubectl'],
  }
}
