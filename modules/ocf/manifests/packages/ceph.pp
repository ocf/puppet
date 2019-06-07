class ocf::packages::ceph {
  ocf::repackage {
    'ceph':
      backport_on => ['buster'];
    'ceph-mds':
      backport_on => ['buster'];
  }
}
