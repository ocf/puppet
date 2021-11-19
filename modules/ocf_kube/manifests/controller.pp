# Each kubernetes controller installs and runs kubelet and CRI-O.
# Kubelet is kubernetes' service that has to run on every node. It is in charge
# of figuring out what containers it has to run, and running them. It can do this
# in two ways: the API server tells it to run something, or we can configure it
# with what containers it should run. There are four containers which we
# need to tell kubelet to run via files to bootstrap the cluster.
# These are as follows:
# 1. kube-apiserver
# 2. kube-controller-manager
# 3. kube-scheduler
# 4. etcd

# In an normal cluster, you would also need to run kube-proxy, in addition to
# kubelet. However, we don't need to, because cilium can replace it.

# After kubelet starts and runs the containers, we should have a working
# kubernetes cluster.

# We use CRI-O over docker because docker is de-facto getting deprecated
# in kubernetes 1.20: https://github.com/kubernetes/kubernetes/pull/94624

# This purpose of this puppet class is to install kubelet and CRI-O, and
# configure the four containers.

class ocf_kube::controller {
  $is_prod = $::hostname in lookup('kube::controller_nodes')
  $is_dev = $::hostname in lookup('kube_dev::controller_nodes')

  if $is_prod and $is_dev {
    fail("${::hostname} is in both the production and the development kubernetes cluster")
  }

  if !$is_prod and !$is_dev {
    fail("${::hostname} is not in any kubernetes cluster")
  }

  # Namespace for hiera variables
  $kube_prefix = if $is_dev { 'kube_dev' } else { 'kube' }

  # Versions!
  $kube_version = lookup("${kube_prefix}::kubernetes_version")
  $kube_package_version = lookup("${kube_prefix}::kubernetes_package_version")
  $etcd_version = lookup("${kube_prefix}::etcd_version")

  # If we are the first controller on the hiera list, we start a new etcd cluster.
  # Otherwise, we tell it to join the existing cluster.
  # We configure the initial cluster as the set of members appearing before us in the
  # hiera list.

  # initial cluster members
  $initial_cluster_hosts = lookup("${kube_prefix}::controller_nodes").reduce([]) |$acc, $node| {
    (($acc != []) and $acc[-1] == $::hostname) ? {
      # If we are on the list, stop adding nodes
      true  => $acc,
      # Otherwise, add the next node, and recurse
      false => $acc.concat($node),
    }
  }

  # (host, IP) pairs of initial cluster
  $initial_cluster = $initial_cluster_hosts.map |$node| {
    [$node, ldap_attr($node, 'ipHostNumber')]
  }

  $initial_cluster_state = if $initial_cluster.length == 1 {
    'new'
  } else {
    'existing'
  }

  # We find containerd located in the docker debian repository
  package { ['cri-o', 'cri-o-runc']: }
  -> file { '/etc/crio/crio.conf':
    source  => 'puppet:///modules/ocf_kube/crio.conf',
  }
  ~> service { 'crio': }

  # install cri-tools for crictl
  package { 'cri-tools': }

  # Ensure /var/lib/etcd has mode 700
  file { '/var/lib/etcd':
    ensure => directory,
    mode   => '0700',
  }

  # Install kubectl
  class { 'ocf::packages::kube::kubectl':
    kubectl_package_version => $kube_package_version,
  }

  # Install kubelet + start service
  class { 'ocf::packages::kube::kubelet':
    kubelet_package_version => $kube_package_version,
  }
  ~> ocf::systemd::service { 'kubelet':
    content => template('ocf_kube/kubelet.service');
  }

  # Ensure that the only contents of /etc/kubernetes are managed by us
  file { '/etc/kubernetes':
    ensure  => directory,
    purge   => true,
    recurse => true,
  }

  # apiserver authentication for other kube services
  file {
    '/etc/kubernetes/kubelet.conf':
      content => template('ocf_kube/kubelet.conf');

    '/etc/kubernetes/controller-manager.conf':
      content => template('ocf_kube/controller-manager.conf');

    '/etc/kubernetes/scheduler.conf':
      content => template('ocf_kube/scheduler.conf');

    '/etc/kubernetes/admin.conf':
      content => template('ocf_kube/admin.conf');
  }

  # remove deb-provided kubelet conf
  file {'/etc/systemd/system/kubelet.service.d':
    ensure  => directory,
    recurse => true,
    purge   => true,
    owner   => 'root',
    group   => 'root',
    mode    => '0755';
  }

  file {
    '/etc/kubernetes/kubelet.yaml':
      content => template('ocf_kube/kubelet.yaml');

    '/etc/kubernetes/manifests':
      ensure => directory;

    '/etc/kubernetes/manifests/kube-apiserver.yaml':
      content => template('ocf_kube/kube-apiserver.yaml');

    '/etc/kubernetes/manifests/kube-controller-manager.yaml':
      content => template('ocf_kube/kube-controller-manager.yaml');

    '/etc/kubernetes/manifests/kube-scheduler.yaml':
      content => template('ocf_kube/kube-scheduler.yaml');

    '/etc/kubernetes/manifests/etcd.yaml':
      content => template('ocf_kube/etcd.yaml');
  }

  file {
    '/etc/kubernetes/pki':
      ensure => directory,
      mode   => '0700';

    '/etc/kubernetes/pki/etcd':
      ensure => directory,
      mode   => '0700';
  }

  if $is_dev {
    $certs_dir = '/opt/puppet/shares/private/kubernetes/dev'
  } else {
    $certs_dir = '/opt/puppet/shares/private/kubernetes/prod'
  }

  # All the PKI infra that kubernetes needs
  ocf::privatefile {
    # apiserver server key
    '/etc/kubernetes/pki/apiserver.crt':
      content_path => "${certs_dir}/apiserver.crt";
    '/etc/kubernetes/pki/apiserver.key':
      content_path => "${certs_dir}/apiserver.key";

    # kubelet server key
    '/etc/kubernetes/pki/kubelet-server.crt':
      content_path => "${certs_dir}/${::hostname}-kubelet-server.crt";
    '/etc/kubernetes/pki/kubelet-server.key':
      content_path => "${certs_dir}/${::hostname}-kubelet-server.key";

    # kubelet -> apiserver client key
    '/etc/kubernetes/pki/apiserver-kubelet-client.crt':
      content_path => "${certs_dir}/apiserver-kubelet-client.crt";
    '/etc/kubernetes/pki/apiserver-kubelet-client.key':
      content_path => "${certs_dir}/apiserver-kubelet-client.key";

    # kubernetes ca
    '/etc/kubernetes/pki/ca.crt':
      content_path => "${certs_dir}/kube-ca.crt";
    # don't copy the private key

    # controller-manager -> apiserver client key
    '/etc/kubernetes/pki/admin.crt':
      content_path => "${certs_dir}/admin.crt";
    '/etc/kubernetes/pki/admin.key':
      content_path => "${certs_dir}/admin.key";

    # controller-manager -> apiserver client key
    '/etc/kubernetes/pki/controller-manager.crt':
      content_path => "${certs_dir}/controller-manager.crt";
    '/etc/kubernetes/pki/controller-manager.key':
      content_path => "${certs_dir}/controller-manager.key";

    # scheduler -> apiserver client key
    '/etc/kubernetes/pki/scheduler.crt':
      content_path => "${certs_dir}/scheduler.crt";
    '/etc/kubernetes/pki/scheduler.key':
      content_path => "${certs_dir}/scheduler.key";

    # service account keypair
    '/etc/kubernetes/pki/sa.pub':
      content_path => "${certs_dir}/service.pub";
    '/etc/kubernetes/pki/sa.key':
      content_path => "${certs_dir}/service.key";

    # etcd ca
    '/etc/kubernetes/pki/etcd/ca.crt':
      content_path => "${certs_dir}/etcd-ca.crt";
    # don't copy the private key

    # apiserver/etcd -> etcd client key
    '/etc/kubernetes/pki/etcd/client.crt':
      content_path => "${certs_dir}/${::hostname}-etcd-client.crt";
    '/etc/kubernetes/pki/etcd/client.key':
      content_path => "${certs_dir}/${::hostname}-etcd-client.key";

    # etcd server key
    '/etc/kubernetes/pki/etcd/server.crt':
      content_path => "${certs_dir}/${::hostname}-etcd-server.crt";
    '/etc/kubernetes/pki/etcd/server.key':
      content_path => "${certs_dir}/${::hostname}-etcd-server.key";

    # front-proxy ca
    '/etc/kubernetes/pki/front-proxy-ca.crt':
      content_path => "${certs_dir}/front-proxy-ca.crt";
    '/etc/kubernetes/pki/front-proxy-ca.key':
      content_path => "${certs_dir}/front-proxy-ca.key";

    # front-proxy client
    '/etc/kubernetes/pki/front-proxy-client.crt':
      content_path => "${certs_dir}/front-proxy-client.crt";
    '/etc/kubernetes/pki/front-proxy-client.key':
      content_path => "${certs_dir}/front-proxy-client.key";
  }

  # TODO: disable swap
}
