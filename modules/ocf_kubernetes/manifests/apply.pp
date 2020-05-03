define ocf_kubernetes::apply(
  $target,
  $config = '/etc/kubernetes/admin.conf',
) {

  exec { "kubectl-apply-${title}":
    environment => ["KUBECONFIG=${config}"],
    command     => "kubectl apply -f ${target}",
    # only apply if there are actually new changes, to avoid spam
    unless      => "kubectl diff -f ${target}",
    require     => Package['kubectl'],
  }
}
