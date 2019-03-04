class ocf::packages::kubectl {
  include ocf::packages::kubernetes

  package { 'kubectl':; }

  $cluster_cert_base64 = base64('encode', lookup('kubernetes::kubernetes_ca_crt'))

  file {
    '/etc/kubectl.conf':
      content => template('ocf/kubectl/kubectl.conf.erb'),
      mode    => '0644',
  }
}
