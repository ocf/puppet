class ocf_staffvm::docker_group {
  if tagged('ocf::packages::docker') {
    require ocf::packages::docker

    $owner = lookup('owner')

    ensure_resource('user', $owner)
    User[$owner] {
      groups +> 'docker'
    }
  }
}
