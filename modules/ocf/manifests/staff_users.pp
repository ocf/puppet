# Create home directories for staff members if NFS isn't mounted.

class ocf::staff_users {
  if !str2bool($::ocf_nfs) and $::type == 'server' {
    $staff = split($::ocf_staff, ',')
    ocf::staff_users::user { $staff:; }
  }
}
