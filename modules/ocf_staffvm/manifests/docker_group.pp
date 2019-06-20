class ocf_staffvm::docker_group {
  if tagged('ocf::packages::docker') {
    require ocf::packages::docker

    $owner = lookup('owner')

    user { $owner:
      groups     => ['docker'],
      system     => false,
      membership => minimum,
    }
  }
}
