# Include the official apt repository for kubernetes
# We use a nested class hack to get puppet to apply this class in the first stage.
class ocf::packages::kube::apt {
  class { 'ocf::packages::kube::apt_first_stage':
    stage => first,
  }
}
