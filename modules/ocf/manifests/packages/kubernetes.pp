# puppetlabs-kubernetes will pull in the package sources
# and install the packages. Staging the key first prevents
# cyclic dependencies.
class ocf::packages::kubernetes {
  class { 'ocf::packages::kubernetes::apt':
    stage => first,
  }
}
