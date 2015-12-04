# Create home directories for staff members if NFS isn't mounted.

class ocf::staff_users {
  # Only create home directories if:
  #   - we don't mount NFS
  #   - we're a server (not a desktop)
  #   - we're not the file server
  if !str2bool($::ocf_nfs) and $::type == 'server' and !tagged('ocf_filehost') {
    $staff = split($::ocf_staff, ',')
    ocf::staff_users::user { $staff:; }
  }
}
