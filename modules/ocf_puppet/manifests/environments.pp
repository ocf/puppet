class ocf_puppet::environments {
  $staff = split($::ocf_staff, ',')
  ocf_puppet::environments::environment { $staff:; }
}
