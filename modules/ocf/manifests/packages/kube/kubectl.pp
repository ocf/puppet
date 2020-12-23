# Installs the kubectl package with the given version.
# Does not configure it.
class ocf::packages::kube::kubectl(
  String $kubectl_package_version,
) {
  include ocf::packages::kube::apt;

  apt::pin { 'kubectl':
    packages => 'kubectl',
    version  => $kubectl_package_version,
    priority => 1001,
  }
  -> package { 'kubectl': }
}
