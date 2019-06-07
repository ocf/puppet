class ocf::packages::ceph {
  class { 'ocf::packages::ceph::apt':
    stage => first,
  }

  package { 'ceph':; }
}
