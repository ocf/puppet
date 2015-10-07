define ocf::staff_users::user($user = $title) {
  $parent1 = regsubst($user, '^([a-z]).*$', '/home/\1')
  $parent2 = regsubst($user, '^([a-z])([a-z]).*$', '/home/\1/\1\2')
  $homedir = regsubst($user, '^([a-z])([a-z])([a-z]*)$', '/home/\1/\1\2/\1\2\3')

  ensure_resource('file', [$parent1, $parent2], {'ensure' => 'directory'})

  file { $homedir:
    ensure  => directory,
    owner   => $user,
    group   => ocfstaff;
  }
}
