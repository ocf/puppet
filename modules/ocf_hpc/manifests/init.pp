class ocf_hpc {
  include ocf::ipmi

  # install proprietary nvidia drivers
  package { ['nvidia-driver', 'nvidia-settings', 'nvidia-cuda-toolkit']:; }
}
