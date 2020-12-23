# Installs the kubelet package with the given version.
# Does not configure it.
class ocf::packages::kube::kubelet(
  String $kubelet_package_version,
) {
  include ocf::packages::kube::apt;

  apt::pin { 'kubelet':
    packages => 'kubelet',
    version  => $kubelet_package_version,
    priority => 1001,
  }
  -> package { 'kubelet': }
}
