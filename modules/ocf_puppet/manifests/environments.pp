class ocf_puppet::environments {
  package { 'r10k':; }

  $staff = split($::ocf_staff, ',')
  ocf_puppet::environments::environment { $staff:; }
}
