# Create home directories for staff members if NFS isn't mounted.

class ocf::staff_users($noop = false) {
  # Only create home directories if:
  #   - we don't mount NFS
  #   - it hasn't been turned off in Hiera
  if !str2bool($::ocf_nfs) and !$noop {
    $staff = split($::ocf_staff, ',')
    ocf::staff_users::user { $staff:; }
  }
}
