# Shared kubernetes private keys, certs, and client certs,
# and tokens for joining the cluster are in
# /opt/puppet/shares/private/kubernetes/os/Debian.yaml.
#
# Unlike master nodes, no special puppet private data
# is necessary, so worker nodes can be trivially scaled
# with the small requirement that kubernetes::worker
# class is added.
class ocf_kubernetes::worker {
  include ocf::packages::docker_kube
  include ocf::packages::kubernetes

  class { 'kubernetes':
    worker        => true,
    # puppetlabs-kubernetes is a little confused here
    manage_docker => false,
    create_repos  => false,
  }
}
