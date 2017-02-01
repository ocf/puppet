# Create home directories for staff members if NFS isn't mounted.

class ocf::staff_users($noop = false) {
  # Only create home directories if:
  #   - we don't mount NFS
  #   - it hasn't been turned off in Hiera
  if !str2bool($::ocf_nfs) and !$noop and $::ocf_staff {
    $staff = split($::ocf_staff, ',')
    $staff.each |$user| {
      $parent1 = regsubst($user, '^([a-z]).*$', '/home/\1')
      $parent2 = regsubst($user, '^([a-z])([a-z]).*$', '/home/\1/\1\2')
      $homedir = regsubst($user, '^([a-z])([a-z])([a-z]*)$', '/home/\1/\1\2/\1\2\3')

      ensure_resource('file', [$parent1, $parent2], {'ensure' => 'directory'})

      file { $homedir:
        ensure  => directory,
        owner   => $user,
        mode    => '0700',
        group   => ocfstaff;
      }
    }
  }
}
