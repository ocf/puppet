class ocf_staffvm {
  $owner = lookup('owner', { 'default_value' => undef })
  if $owner == undef {
    fail('A staffvm must have an owner defined in hiera!')
  }

  include ocf_staffvm::docker_group
  include ocf_staffvm::firewall
}
