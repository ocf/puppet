# This class is relatively lightweight because much of the
# kubeadm init bootstrapping is handled by the
# puppetlabs-kubernetes module. Master definitions for etcd
# server certs, keys, peer certs and keys are in:
# /opt/puppet/shares/private/kubernetes/hosts/myhost.yaml.
# This file is generated by puppetlabs kubetool.
#
# Shared kubernetes private keys, certs, and client certs,
# and tokens for joining the cluster are in
# /opt/puppet/shares/private/kubernetes/os/Debian.yaml.
# This file is also generated by puppetlabs kubetool.
#
# Non sensitive generated configuration data is in common.yaml.
class ocf_kubernetes::master {
  include ocf::packages::docker_kubernetes
  include ocf::packages::kubernetes
  include ocf_kubernetes::master::loadbalancer
  include ocf_kubernetes::master::webui

  $etcd_version = lookup('kubernetes::etcd_version')
  $etcd_archive = "etcd-v${etcd_version}-linux-amd64.tar.gz"
  $etcd_source  = "https://github.com/etcd-io/etcd/releases/download/v${etcd_version}/${etcd_archive}"
  $etcd_peers = lookup('kubernetes::etcd_peers')

  # Allow kubernetes to talk to each other on all ports.
  # This includes etcd ports 2378, 2379, and others
  # for internal kubernetes communication.
  firewall_multi {
    '101 allow kubernetes master communication (IPv4)':
      chain  => 'PUPPET-INPUT',
      source => $etcd_peers,
      proto  => ['tcp', 'udp'],
      action => 'accept',
      before => Class['kubernetes']
  }

  # Passwords for the static token file
  # https://kubernetes.io/docs/reference/access-authn-authz/authentication/#static-token-file
  $ocf_jenkins_deploy_token = lookup('kubernetes::jenkins_token')

  # Used for dashboard users
  $ocf_admin_token = lookup('kubernetes::admin_token')
  $ocf_viewer_token = lookup('kubernetes::viewer_token')

  file {
    '/etc/ocf-kubernetes':
      ensure  => directory,
      recurse => true,
      purge   => true;

    '/etc/ocf-kubernetes/manifests':
      ensure => directory,
      mode   => '0700';

    '/etc/ocf-kubernetes/static-tokens.csv':
      content   => template('ocf_kubernetes/static-tokens.csv.erb'),
      mode      => '0400',
      show_diff => false;

    '/etc/ocf-kubernetes/abac.jsonl':
      source => 'puppet:///modules/ocf_kubernetes/abac.jsonl',
      mode   => '0755';

    '/etc/ocf-kubernetes/manifests/rbac.yaml':
      source => 'puppet:///modules/ocf_kubernetes/rbac.yaml',
      mode   => '0755';
  }

  ocf_kubernetes::apply {
    'rbac':
      target    => '/etc/ocf-kubernetes/manifests/rbac.yaml',
      subscribe => File['/etc/ocf-kubernetes/manifests/rbac.yaml'];
  }

  # These are needed because puppetlabs-kubernetes sets the permissions to 600
  # but the certsign script, running under kubernetes-ca, needs to access them

  File['/etc/kubernetes/pki'] {
    owner  => 'kubernetes-ca',
  }

  File['/etc/kubernetes/pki/ca.crt'] {
    owner  => 'kubernetes-ca',
  }

  File['/etc/kubernetes/pki/ca.key'] {
    owner  => 'kubernetes-ca',
  }

  class { 'kubernetes':
    controller                => true,
    manage_etcd               => true,
    # note that etcd_* variables are chained.
    # This will be fixed in an upcoming version, and
    # we will only have to specify etcd_version.
    etcd_version              => $etcd_version,
    etcd_archive              => "etcd-v${etcd_version}-linux-amd64.tar.gz",
    etcd_source               => "https://github.com/etcd-io/etcd/releases/download/v${etcd_version}/etcd-v${etcd_version}-linux-amd64.tar.gz",
    install_dashboard         => false,
    # If we let puppetlabs-kubernetes manage docker then
    # there are dependency issues because they apt add key
    # is not staged before the package is added.
    manage_docker             => false,
    create_repos              => false,

    apiserver_cert_extra_sans => [
      'kubernetes.ocf.berkeley.edu',
    ],

    apiserver_extra_arguments => [
      'authorization-mode: Node,RBAC,ABAC',
      'token-auth-file: /etc/ocf-kubernetes/static-tokens.csv',
      'authorization-policy-file: /etc/ocf-kubernetes/abac.jsonl',
    ],

    apiserver_extra_volumes   => {
      'ocf-auth' => {
        hostPath  => '/etc/ocf-kubernetes',
        mountPath => '/etc/ocf-kubernetes',
      },
    },
  }

  user { 'kubernetes-ca':
    ensure =>  present,
    name   =>  'kubernetes-ca',
    groups =>  [sys],
    shell  =>  '/bin/false',
    system =>  true,
  }

  # Override the Kubernetes configuration directory, created by
  # the puppetlabs-kubernetes config module, to have owner kubernetes-ca
  # and not be readable by any user
  File<|title == '/etc/kubernetes'|> {
    owner => 'kubernetes-ca',
    mode  => '0700',
  }

  # cert signing script
  file {
    '/usr/local/bin/certsign':
      mode   => '0755',
      source =>'puppet:///modules/ocf_kubernetes/certsign';

    '/etc/sudoers.d/certsign':
      content =>  "ALL ALL=(kubernetes-ca) NOPASSWD: /usr/local/bin/certsign\n";
  }

  file {
    '/etc/profile.d/kubeconfig.sh':
      mode    => '0755',
      source  => 'puppet:///modules/ocf_kubernetes/kubeconfig.sh',
      require => Class['kubernetes'],
  }

  class { 'ocf_kubernetes::master::ingress::nginx':
    require => Class['kubernetes'],
  }

  class { 'ocf_kubernetes::master::persistent_volume':
    require => Class['kubernetes'],
  }

  class { 'ocf_kubernetes::master::secrets':
    require => Class['kubernetes'],
  }
}
